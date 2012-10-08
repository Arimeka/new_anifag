namespace :db do  

  task old_data: :environment do
    desc "Fill database with old data"
    f = File.open("public/blog-backup.xml", "r")
    doc = Nokogiri::XML(f)
    f.close
    @user = User.create!(name: "User",
                 email: "user@example.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    @user.create_user_description(role: "admin")      
    @user.toggle!(:admin)       
    doc.css('entry').each do |post|
      if post.css('uri').children.text == "https://plus.google.com/id" && post.css('id').children.text =~ /.post-/
        mass = []
        tags = []
        cat = [] 
        if post.css('content').children.text.index("<a name='more'></a>")
          mass = post.css('content').children.text.split("<a name='more'></a>")
        else
          mass[0] = post.css('content').first.children.text
          mass[1] = ''
        end
        content = mass[0] + mass[1]
        description = mass[0]
        title = post.css('title').children.text
        permalink = ''

        post.css('link').each do |link|
          if link["rel"] == "alternate"
            permalink = link["href"][/(http:\/\/www.anifag.com\/)(\d+\/\d+\/)(.+)(.html)/,3]
          end
        end

        created_at = post.css('published').children.text
        updated_at = post.css('updated').children.text
        
        post.css('category').each do |tag|          
          if tag["term"] != "http://schemas.google.com/blogger/2008/kind#post"
            if tag["term"] != "news" && 
               tag["term"] != "anime" && 
               tag["term"] != "manga"
              tags.push tag["term"]
            else
              cat.push tag["term"]
            end
          end
        end
        
        if Sanitize.clean(description).length > 160
          meta_description = Sanitize.clean(description)[0..160] + '...'
        else
          if Sanitize.clean(description).length > 50
            meta_description = Sanitize.clean(description)[0..160]
          else
            meta_description = ''
          end
        end

        @article = @user.articles.build(content: content, description: description,
                                        title: title, permalink: permalink, draft: permalink.blank? ? true : false,
                                        created_at: created_at, updated_at: updated_at, tags: tags,
                                        keywords: tags.join(','), meta_description: meta_description)
        @article.save 
                             
        if cat.any?
           cat.each do |x|
            name = Russian.translit(x).downcase.split.map { |n| n[/\w+/] }.join('-')
            if Category.find_by_name(name)
              @article.categories << Category.find_by_name(name)
            else
              @article.categories.create(name: name, title: x)
            end
          end
        end
      end
    end
  end
end