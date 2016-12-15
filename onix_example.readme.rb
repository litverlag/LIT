#!/usr/bin/ruby
#$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'onix'
h = ONIX::Header.new
h.from_company = "Lit Verlag"
h.from_person = "Wilhelm Hopf"
h.sent_date = Time.now
writer = ONIX::Writer.new($stdout, h)
p = ONIX::APAProduct.new
p.notification_type = 2
p.record_reference = 1
p.isbn10 = "1844836902"
p.isbn13 = "9781844836901"
p.title = "1001 Pearls of Bible Wisdom"
p.subtitle = "Boo"
p.supplier_website = "http://www.lit-verlag.de"
p.add_contributor("Guy, That")
p.imprint = "Malhame"
p.publisher = "Dover"
p.sales_restriction_type = 0
p.supplier_name = "Rainbow Agencies"
p.supplier_phone = "+61 3 9481 6611"
p.supplier_fax = "+61 3 9481 2371"
p.supplier_email = "versand@lit-verlag.de"
p.supply_country = "DE"
p.product_availability = 20
#p.on_hand = 10
#p.on_order = 20
#p.rrproduct_inc_sales_tax = 29.95
writer << p
writer.end_document
