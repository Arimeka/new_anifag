xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Anime Fag"
    xml.description "Новости аниме и манги"
    xml.link root_url

    @articles.each do |article|
      xml.item do
        article.tags.each do |x|
          xml.category x
        end
        xml.author do
          xml.name article.user.name
          xml.uri user_url(article.user)
        end
        xml.title article.title
        xml.description article.description + (article.description != article.content ? link_to("Читать дальше", article_url(article)) : '')
        xml.pubDate article.created_at.to_s(:rfc822)
        xml.link article_url(article)
        xml.guid article_url(article)
      end
    end
  end
end