module ApplicationHelper
  # Returns the full title on a per-page basis.       
  def full_title(page_title)                          
    base_title = "Anime Fag"  
    if page_title.empty?                              
      base_title                                      
    else
      "#{page_title} - #{base_title}"                 
    end
  end
  
  def show_content(content)
    check_css = lambda { |env|
                        node      = env[:node]
                        node_name = env[:node_name]
                        # Don't continue if this node is already whitelisted or is not an element.
                        return if env[:is_whitelisted] || !node.element?
                        parent = node.parent
                        return unless node_name == 'style' || node['style']
                        if node_name == 'style'
                          unless good_css? node.content
                            node.unlink
                            return
                          end
                        else
                          unless good_css? node['style']
                            node.unlink
                            return
                          end
                        end
                        {:node_whitelist => [node]}
                      }
                      
    video_emb = lambda do |env|
                    node      = env[:node]
                    node_name = env[:node_name]
                                      
                    return if env[:is_whitelisted] || !node.element?
                                      
                    return unless node_name == 'iframe' || 
                                  node_name == 'object' || 
                                  node_name == 'param'  || 
                                  node_name == 'embed'
                                      
                    return unless node['src'] =~ /\Ahttps?:\/\/(?:www\.)?(youtube(?:-nocookie)?\.com)|(ustream\.tv)|(vimeo\.com)\//
                  
                    Sanitize.clean_node!(node, {
                      :elements => %w[iframe object param embed],
                  
                      :attributes => {
                        'iframe'  => %w[allowfullscreen frameborder height src width webkitallowfullscreen mozallowfullscreen],
                        'object' => %w[width height],
                        'param' => %w[name value],
                        'embed' => %w[src type allowfullscreen allowScriptAccess width height],
                      }
                    })

                    {:node_whitelist => [node]}
                  end
                      
    Sanitize.clean(content, :elements => ['p', 'blockquote', 'pre', 'h3', 'h4', 'h5', 'h6',
                                          'b', 'i', 'strike', 'ul', 'li', 'span', 'ol',
                                          'img', 'br', 'table', 'tbody', 'thead', 'tr', 
                                          'td', 'th', 'caption', 'a', 'font', 'hr', 'div'],
                            :attributes => {
                                              'a'  => ['href', 'title', 'target'],
                                              'font' => ['color'],
                                              'img' => ['border', 'height', 'src', 'width']
                                            },
                            :transformers => [check_css, video_emb])    
  end
  
  def good_css?(text)
    return false if text =~ /(\w\/\/)/    # a// comment immediately following a letter
    return false if text =~ /(\w\/\/*\*)/ # a/* comment immediately following a letter
    return false if text =~ /(\/\*\/)/            # /*/ --> hack attempt, IMO

    # Now, strip out any comments, and do some parsing.
    no_comments = text.gsub(/(\/\*.*?\*\/)/, "") # filter out any /* ... */
    no_comments.gsub!("\n", "")
    # No backslashes allowed
    evil = [
      /(\bdata:\b|eval|cookie|\bwindow\b|\bparent\b|\bthis\b)/i, # suspicious javascript-type words
      /behaviou?r|expression|moz-binding|@import|@charset|(java|vb)?script|[\<]|\\\w/i,
      /[\<>]/, # back slash, html tags,
      /[\x7f-\xff]/, # high bytes -- suspect
      /[\x00-\x08\x0B\x0C\x0E-\x1F]/, #low bytes -- suspect
      /&\#/, # bad charset
      /(position|padding|(\s+|:)\d{4,}\w{0,2};)/i
    ]
    good = [
      /()/i
    ]
    evil.each { |regex| return false if no_comments =~ regex }
    true
  end
  
  def tag_cloud(limit)
    @tags = Article.not_draft.popular_tags
        
    @tag_cloud_hash = {}
    minFontSize = 10
    maxFontSize = 40 
    
    unless @tags.empty?
      minOccurs = @tags.reverse.first.tags_count
      maxOccurs = @tags.first.tags_count
      min = (maxOccurs-minOccurs)/@tags.count
      @tags.each do |tag|
        if maxOccurs == minOccurs
          size = 13
        else
          weight = (tag.tags_count-minOccurs).to_f/(maxOccurs-minOccurs)
          size = minFontSize + ((maxFontSize-minFontSize)*weight).round
        end
        @tag_cloud_hash[tag.id] = size
      end
    end
    if limit && @tags.count > 10
      @tags = Article.not_draft.popular_tags(min: min)
    end 
  end
  
  def archive_list(year)
    @archive_year_count = Article.last_year(year).not_draft.count
    @archive_month_count = []
    if Time.new(year).year == Time.now.year      
      1.upto(12) do |x|
        if x < 12
          @archive_month_count.push(Article.last_month(year,x).not_draft.count)
        else
          @archive_month_count.push(Article.end_year(year,x).not_draft.count)
        end
      end
    end
  end
  
  def adv_aside
    advertisement = []
    advertisement = [
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_669235" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-ihbd-6-2-78-2i-29-344-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_669235" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe src="http://rcm.amazon.com/e/cm?t=anifag-20&o=1&p=14&l=st1&mode=toys&search=figma nendoroid figures anime&fc1=000000&lt1=_blank&lc1=3366FF&bg1=FFFFFF&f=ifr" marginwidth="0" marginheight="0" width="160" height="600" border="0" frameborder="0" style="border:none;" scrolling="no"></iframe></div>
      ',
      '
        <a href="http://www.1999.co.jp/eng/238-0-1-49.html" target="_blank"><img border="0" src="http://www.1999.co.jp/idevaffiliate/banners/200-300.jpg" width="200" height="300" /></a>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><a href="http://printdirect.ru/index.php?mode=storefront&submit_search=1&search_keyword=%e0%ed%e8%ec%e5&partner_id=209270" target="_blank"><img border="0" src="http://1.bp.blogspot.com/--aLtSZHNypk/TvgFZGWj9YI/AAAAAAAANOU/CewHY60MJbE/s1600/pd.jpg" title="anime@printdirect.ru" /></a></div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_146799" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-knv6-6-2-78-2i-29-1767-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_146799" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_601899" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-ci0b-6-2-78-2i-29-1771-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_601899" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_360537" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-h3av-6-2-78-2i-29-1783-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_360537" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_338637" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-7dn6-6-2-78-2i-29-1743-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_338637" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_872326" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-b8j4-6-2-78-2i-29-1753-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_872326" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_553159" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-70bi-6-2-78-2i-29-1779-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_553159" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_431680" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-mpn-6-2-78-2i-29-1775-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_431680" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_629546" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-7ftr-6-2-78-2i-29-1749-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_629546" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_817471" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-u4d-6-2-78-2i-29-1769-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_817471" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_305571" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-7d7z-6-2-78-2i-29-1781-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_305571" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><iframe id="id01_670666" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-81-1-76-6-70-j2mq-6-2-78-2i-29-1745-90-mhar-33-iframe_banner-44-140px.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="140px" height="925"></iframe>
          <script type="text/javascript">
          var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_670666" ); iframe.src = iframe.src.replace( "iframe_banner", t );
          </script>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><a href="http://www.1999.co.jp/eng/238-0-1-11.html" target="_blank"><img border="0" src="http://www.1999.co.jp/idevaffiliate/banners/140x600.jpg" width="140" height="600" alt=""></a>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><a href="http://www.1999.co.jp/eng/238-0-1-12.html" target="_blank"><img border="0" src="http://www.1999.co.jp/idevaffiliate/banners/160x300.jpg" width="160" height="300" alt=""></a>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><a href="http://www.1999.co.jp/eng/238-0-1-19.html" target="_blank"><img border="0" src="http://www.1999.co.jp/idevaffiliate/banners/200x230.jpg" width="200" height="230" alt=""></a>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><a href="http://www.1999.co.jp/eng/238-0-1-45.html" target="_blank"><img border="0" src="http://www.1999.co.jp/idevaffiliate/banners/120-300.jpg" width="120" height="300" alt=""></a></div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><a href="http://www.1999.co.jp/eng/238-0-1-46.html" target="_blank"><img border="0" src="http://www.1999.co.jp/idevaffiliate/banners/120-300_2.jpg" width="120" height="300" alt=""></a>
        </div>
      ',
      '
        <div class="separator" style="clear: both; text-align: center;"><a href="http://www.1999.co.jp/eng/238-0-1-48.html" target="_blank"><img border="0" src="http://www.1999.co.jp/idevaffiliate/banners/140-600.jpg" width="140" height="600" alt=""></a>
        </div>
      '
    ]
    advertisement.sample
  end
  
  def adv_horizontal
    advertisement = []
    advertisement = [
      '
        <iframe id="id01_270700" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-bw6j-6-2-78-2i-29-1461-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_270700" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      ',
      '
        <iframe id="id01_976187" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-fere-6-2-78-2i-29-344-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_976187" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      ',
      '
        <iframe id="id01_647985" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-4nkp-6-2-78-2i-29-1743-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_647985" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      ',
      '
        <iframe id="id01_731574" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-bsy0-6-2-78-2i-29-1779-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_731574" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      ',
      '
        <iframe id="id01_676684" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-22f8-6-2-78-2i-29-1775-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_676684" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      ',
      '
        <iframe id="id01_761362" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-eqs4-6-2-78-2i-29-1749-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_761362" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      ',
      '
        <iframe id="id01_168983" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-c5u1-6-2-78-2i-29-1745-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_168983" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      ',
      '
        <iframe id="id01_627471" src="http://www.play-asia.com/paOS-38-19-0%2C000000%2Cnone%2C0%2C0%2C0%2C0%2CFFFFFF%2C000000%2Cleft%2C1%2C0-39-1-81-1-76-5-70-8q1p-6-2-78-2i-29-1777-90-mhar-33-iframe_banner-44-100%252525.html" style="border-style: none; border-width: 0px; border-color: #000000; padding: 0px; margin: 0px; scrolling: no; frameborder: 0;" scrolling="no" frameborder="0" width="100%25" height="198"></iframe>
        <script type="text/javascript">
        var t = ""; t += window.location; t = t.replace( /#.*$/g, "" ).replace( /^.*:\/*/i, "" ).replace( /\./g, "[dot]" ).replace( /\//g, "[obs]" ).replace( /-/g, "[dash]" ); t = encodeURIComponent( encodeURIComponent( t ) ); var iframe = document.getElementById( "id01_627471" ); iframe.src = iframe.src.replace( "iframe_banner", t );
        </script>
      '
    ]
    advertisement.sample
  end
end
