# coding: utf-8
module UsersHelper
  
  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 200 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
  
  def user_role(user)
    if user.admin?
      "Админ"
    else
      case user.user_description.role
      when "newsmaker"
        "Новости"
      when "editor"
        "Редактор"
      else
        "Пользователь"
      end
    end
  end
  
  def create_links(links)
    @mass = []
    var = links.split("\r\n")
    var.each do |x|
      if x =~ /(.+) - (htt(p|ps):\/\/.+\.\w+.*\/$)/ 
        @mass.push( { name: x[/(.+) - ((ht|f)tp(s?)\:\/\/[0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*(:(0-9)*)*(\/?)([a-zA-Z0-9\-\.\?\,\'\/\\\+&amp;%\$#_]*)?$)/, 1], 
                      link: x[/(.+) - ((ht|f)tp(s?)\:\/\/[0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*(:(0-9)*)*(\/?)([a-zA-Z0-9\-\.\?\,\'\/\\\+&amp;%\$#_]*)?$)/, 2] } )
      end     
    end
    @mass
  end  
end
