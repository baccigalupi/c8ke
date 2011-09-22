describe 'css.js' do  
   
  # specs don't change state, add variables, so using $browser for test spec     
  
  [ "CSS2Properties", "CSSRule", "CSSStyleRule", "CSSImportRule", 
    "CSSMediaRule", "CSSFontFaceRule", "CSSPageRule",  
    "CSSStyleSheet", "StyleSheet", "StyleSheetList" ].each do |js_function|
    it "#{js_function} should be available" do
      assert { js("new #{js_function}({}) instanceof #{js_function}") }
    end
  end
  
  it "CSSRuleList should be available" do
    assert { js("new CSSRuleList([]) instanceof CSSRuleList") }
  end 
end

