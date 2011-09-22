describe 'html.js' do   
  # specs don't change state, add variables, so using $browser for test spec     
  
  [ 'HTMLDocument', 'HTMLElement','HTMLAnchorElement', 
    'HTMLAreaElement', 'HTMLBaseElement', 'HTMLQuoteElement', 'HTMLBodyElement', 
    'HTMLBRElement', 'HTMLButtonElement', 'CanvasRenderingContext2D', 'HTMLCanvasElement', 
    'HTMLTableColElement', 'HTMLModElement', 'HTMLDivElement', 'HTMLDListElement', 
    'HTMLFieldSetElement', 'HTMLFormElement', 'HTMLFrameElement', 'HTMLFrameSetElement', 
    'HTMLHeadElement', 'HTMLHeadingElement', 'HTMLHRElement', 'HTMLHtmlElement', 
    'HTMLIFrameElement', 'HTMLImageElement', 'HTMLInputElement', 'HTMLLabelElement', 
    'HTMLLegendElement', 'HTMLLIElement', 'HTMLLinkElement', 'HTMLMapElement', 
    'HTMLMetaElement', 'HTMLObjectElement', 'HTMLOListElement', 'HTMLOptGroupElement', 
    'HTMLOptionElement', 'HTMLParagraphElement', 'HTMLParamElement', 'HTMLPreElement', 
    'HTMLScriptElement', 'HTMLSelectElement', 'HTMLSpanElement', 'HTMLStyleElement', 
    'HTMLTableElement', 'HTMLTableSectionElement', 'HTMLTableCellElement', 
    'HTMLTableDataCellElement', 'HTMLTableHeaderCellElement', 'HTMLTableRowElement', 
    'HTMLTextAreaElement', 'HTMLTitleElement', 'HTMLUListElement', 'HTMLUnknownElement'].each do |js_function|
      it "#{js_function} should be available" do
        assert { js("new #{js_function}({}) instanceof #{js_function}") }
      end
    end
    
    # '__loadImage__', '__loadLink__'
    
  describe 'functions dependent on a document' do  
    # 'HTMLCollection',  'Image'
    before do
      js <<-JS
        document = new Document();
      JS
    end
    
    ['Option'].each do |js_function|
      it "#{js_function} should be available" do
        assert { js("new #{js_function}() instanceof #{js_function}") }
      end
    end
  end
end