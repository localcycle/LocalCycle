desc "EMAILING list of ineligible students to admins"
task :seed_products => :environment do
  
  Product.all.each do |p|
    begin
      p.pic = File.open("app/assets/images/product_pics/#{p.name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}.jpg")
      p.save!
      puts "Found Product: app/assets/images/product_pics/#{p.name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}.jpg"
    rescue 
      next
    end
  end
  
  Category.roots.each do |c|
    begin
      c.pic = File.open("app/assets/images/category_pics/#{c.name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}.jpg")
      c.save!
      puts "Found category: app/assets/images/category_pics/#{c.name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}.jpg"
    rescue
      next
    end
  end
end

task :fix_products => :environment do  
  Product.all.each do |p|
    puts Category.where(id: p.category_id).first.name + " " + p.name if Product.where(name: p.name).count > 1
  end
end

task :agreements_nil_to_zero => :environment do  
  Agreement.all.each do |a|
    a.update_column("producer_id", 0) if a.producer_id == nil
    a.update_column("buyer_id", 0) if a.buyer_id == nil
  end
end
