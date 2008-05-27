require 'caboose'

module Caboose::SpiderIntegrator

  def consume_page( html, url )
    body = HTML::Document.new html
    body.find_all(:tag=>'a').each do |tag|
      queue_link( tag, url )
    end
    body.find_all(:tag =>'form').each do |form|
      queue_form( form, url )
    end
  end
  
  def spider( body, uri )
    @links_to_visit, @forms_to_visit = [], []
    @visited_uris = { '/logout' => true }
    @visited_forms = { '/login' => true }
    @visited_uris[uri] = true
    @errors, @stacktraces = [], []
    
    consume_page( body, uri )
    until @links_to_visit.empty?
      next_link = @links_to_visit.shift
      next if @visited_uris[next_link.uri]
      # puts next_link.uri

      if next_link.uri =~ /\.(html|png|jpg|gif)$/ # static file, probably.
        if File.exist?("#{RAILS_ROOT}/public/#{next_link.uri}")
          @response.body = File.open("#{RAILS_ROOT}/public/#{next_link.uri}").read
          printf "."
        else
          printf "?"
          @errors << "File not found: #{next_link.uri} from #{next_link.source}"
        end
      else
        get next_link.uri
        if %w( 200 302 401 ).include?( @response.code )
          printf '.'
        elsif @response.code == 404
          printf '?'
        else
          printf '!'
          @errors << "Received response code #{ @response.code } for URI #{ next_link.uri } from #{ next_link.source }"
          @stacktraces << @response.body
        end
      end
      consume_page( @response.body, next_link.uri )
      @visited_uris[next_link.uri] = true
    end

    puts "\nTesting forms.."
    until @forms_to_visit.empty?
      next_form = @forms_to_visit.shift
      next if @visited_forms[next_form[:action]]
      # puts "#{next_form[:method]} : #{next_form[:action]} with #{next_form[:query].inspect}"
      printf '.'
      begin
        send(next_form[:method], next_form[:action], next_form[:query])
      rescue => err
        printf "*"
        @errors << "Could not spider page #{next_form[:action]} because of error #{err.message}"
      end
      unless %w( 200 302 401 ).include?( @response.code )
        @errors << "Received response code #{ @response.code } for URI #{ next_form[:action] } from #{ next_form[:source] }"
      end
      consume_page( @response.body, next_form[:action] )
      @visited_forms[next_form[:action]] = true
    end
    puts "\nFinished with #{@errors.size} error(s)."
    assert @errors.empty?, "\n\n=========================\n#{@errors.join("\n")}\n======================Stacktraces:\n#{@stacktraces.join("\n==========\n")}"
  end

  # Adds all <a href=..> links to the list of links to be spidered.
  # If it finds an Ajax.Updater url, it'll call that too.
  def queue_link( tag, source )
    dest = (tag.attributes['onclick'] =~ /^new Ajax.Updater\(['"].*?['"], ['"](.*?)['"]/i) ? $1 : tag.attributes['href']
    unless dest =~ %r{^(http://|mailto:|#)}
      dest = dest.split('#')[0] if dest.index("#") # don't want page anchors
      @links_to_visit << Link.new( dest, source ) if dest.any? # could be empty, make sure there's no empty links queueing
    end
  end
  
  def create_data(input)
    case input['name']
    when /amount/: rand(10000) - 5000
    when /uploaded_data/: # attachment_fu
      nil
    else
      rand(10000).to_s
    end
  end
  
  def queue_form( form, source )
    form_method = form['method']
    form_action = form['action']
    form_action = source if form_action.nil? or form_action.empty?

    input_hash = {}
    form.find_all(:tag => 'input').each do |input|
      if input['name'] == '_method' # and value.in?['put','post',..] # rails is faking the post/put etc
        form_method = input['value']
      else
        if input['type'] == 'hidden'
          input_hash[ input['name'] ] = create_data(input)
        else
          input_hash[ input['name'] ] = input['value'] || create_data(input)
        end
      end
    end
    form.find_all(:tag => 'textarea').each do |input|
      input_hash[ input['name'] ] = input['value'] || create_data(input)
    end

    @forms_to_visit << { :method => form_method, :action => form_action, :query => input_hash, :source => source }
  end

  Link = Struct.new( :uri, :source )

end 