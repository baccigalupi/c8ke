require File.dirname(__FILE__) + '/../spec_helper'

describe 'dom.js' do
  before do
    setup_browser_and_mocking
  end
  
  describe 'defined fundamental object/functions' do
    it 'DOMException' do
      assert { js "new DOMException(DOMException.NAMESPACE_ERR) instanceof DOMException" }
    end
  
    it 'DOMImplementation' do
      assert { js "new DOMImplementation() instanceof DOMImplementation" }
    end
    
    it 'Document' do
      assert { js "new Document() instanceof Document" }
    end
    
    it 'DocumentFragment' do
      assert { js "new DocumentFragment({}) instanceof DocumentFragment" }
    end
    
    it 'Node' do
      assert { js "new Node() instanceof Node" }
    end
    
    it 'NodeList' do
      assert { js "new NodeList() instanceof NodeList" }
    end
    
    it 'NamedNodeMap' do
      assert { js "new NamedNodeMap() instanceof NamedNodeMap" }
    end
    
    it 'CharacterData' do
      assert { js "new CharacterData() instanceof CharacterData" }
    end
    
    it 'Text' do
      assert { js "new Text() instanceof Text" }
    end
    
    it 'Comment' do
      assert { js "new Comment() instanceof Comment" }
    end

    it 'Attr' do
      assert { js "new Attr({}) instanceof Attr" }
    end
    
    it 'Element' do
      assert { js "new Element({}) instanceof Element" }
    end
  end
  
  describe 'defines extended object/functions' do
    it 'CDATASection' do
      assert { js "new CDATASection({}) instanceof CDATASection" }
    end
    
    it 'DocumentType' do
      assert { js "new DocumentType({}) instanceof DocumentType" }
    end
    
    it 'Entity' do
      assert { js( "!!Entity.constants" ) == true }
    end
    
    it 'ProcessingInstruction' do
      assert { js "new ProcessingInstruction({}) instanceof ProcessingInstruction" }
    end
    
    it 'XMLSerializer' do
      assert { js "new XMLSerializer({}) instanceof XMLSerializer" }
    end 

    it 'Namespace' do
      assert { js "new Namespace({}) instanceof Namespace" }
    end 
  end
end 

        