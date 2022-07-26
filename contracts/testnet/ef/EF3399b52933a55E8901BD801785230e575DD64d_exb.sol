// SPDX-License-Identifier: MIT
// @author: Exotic Technology LTD




pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ownable.sol";
import "./ERC721enumerable.sol";
import "./merkle.sol";





contract exb is Ownable, ERC721, ERC721Enumerable {
    
    
    
    bool public saleIsActive = false;

    bool public claim = true;

    uint256 public claimed = 0;

    uint256 constant public  MAX_TOKEN = 1000;

    uint256 constant public MAX_PUBLIC_MINT = 2;
    
    uint256  public royalty = 100;

    uint256 public startingIndex  = 0;

    uint256 public startingIndexBlock  = 0;

    uint256 public SALE_START = 0;

    uint256 public PRE_SALE = 0;

    uint teamReserve = 0;

    string private _baseURIextended;

    string public PROVENANCE;

    bytes32 public ogMerkle = 0x494288747dde61199ca88135f5dce255660112851d8d2529145337199df551f2;

    
    
     // must impl this in your NFT contract, and make it public
    uint256 public LAUNCH_MAX_SUPPLY;    // max launch supply
    uint256 public LAUNCH_SUPPLY = 100;        // current launch supply

    address public LAUNCHPAD;

    modifier onlyLaunchpad() {
        require(LAUNCHPAD != address(0), "launchpad address must set");
        require(msg.sender == LAUNCHPAD, "must call by launchpad");
        _;
    }

    function getMaxLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_MAX_SUPPLY;
    }

    function getLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_SUPPLY;
    }

    mapping(address => uint) public minters;
    
    mapping(address => bool) private senders;
    
    mapping(uint => bool) private claimedLvs;
    mapping(uint => bool) private claimedXoxo;

    
    constructor(address launchpad) ERC721("EXB", "EXB") {
       

        _baseURIextended = "ipfs://QmYpTwhjtVBQL8AvxJGj7bRBsd19sZpiYLemPRhU8h52L1/"; //cover

        senders[msg.sender] = true; // add owner
        
        SetStartingIndexBlock();
        //setStartingIndex();
        //launchSale();

        
        LAUNCHPAD = launchpad;
        LAUNCH_MAX_SUPPLY = MAX_TOKEN;

    }

     


    function updateOgMerkle(bytes32  _root)public {
       require(senders[_msgSender()]);
       ogMerkle = _root;
    }

 

    function prooveMerkle(bytes32[] calldata _merkleProof, bytes32 _merkleRoot)private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));

        require(MerkleProof.verify(_merkleProof, _merkleRoot, leaf),"merkle");

        return true;
    }


   function addSender(address _address) public onlyOwner  {
        
        require(_address != address(0));
        senders[_address] = true;
       
    }
    
    function removeSender(address _address) public onlyOwner {
        require(_address != address(0));
        senders[_address] = false;
        
    }

    function SetStartingIndexBlock() public onlyOwner {
        require(startingIndex == 0);
        
        startingIndexBlock = block.number;
    }

    function setStartingIndex() public onlyOwner {
        require(startingIndex == 0);
        require(startingIndexBlock != 0);
        
        startingIndex = uint(blockhash(startingIndexBlock)) % (MAX_TOKEN);
        // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
        if (block.number - startingIndexBlock > 255) {
            startingIndex = uint(blockhash(block.number - 1)) % (MAX_TOKEN);
        }
        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex++;
        }
    }




   function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view override  returns (
        address receiver,
        uint256 royaltyAmount
    ){
        require(_exists(_tokenId));
        return (owner(), uint256(royalty * _salePrice / 1000));

    }


    function flipSaleState() public  {
        require(senders[_msgSender()]);
        saleIsActive = !saleIsActive;
    }

    function flipclaim() public  {
        require(senders[_msgSender()]);
        claim = !claim;
    }


    function updateRoyalty(uint newRoyalty) public onlyOwner {
        royalty = newRoyalty ;
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
            super._beforeTokenTransfer(from, to, tokenId);
        }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
            return super.supportsInterface(interfaceId);
        }

    function setBaseURI(string memory baseURI_)  external {
             require(senders[_msgSender()]);
            _baseURIextended = baseURI_;
        }

    function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
        }

    function setProvenance(string memory provenance) public onlyOwner {
            PROVENANCE = provenance;
        }



    function getSaleState() public view returns (bool) {
            return saleIsActive;
    }

  


    function launchPreSale() public  {
        require(senders[_msgSender()]);
        require(SALE_START == 0 );
        require(PRE_SALE == 0 );
        require(startingIndex != 0);

        PRE_SALE = 1 ; // 
        saleIsActive = true;
        claim = true;
        
    }

    function launchSale() public  {
        require(senders[_msgSender()]);
        require(SALE_START == 0 );

        PRE_SALE = 0 ; // 
        SALE_START = 1;
        saleIsActive = true;
        claim = true;
        
    }


    
    function _confirmMint(uint _tokenNumber) private view returns (bool) {
        
        uint256 ts = totalSupply();
       
       
        require(!Address.isContract(_msgSender()),"contract");
        require(saleIsActive, "closed!");
        require(ts + _tokenNumber <= MAX_TOKEN, "maxTotal");
        

       

        return true;
    }



    function _doMint(uint numberOfTokens, address _target)private {
        
            minters[_msgSender()]++;   

            uint256 t = totalSupply();

            for (uint256 i = 0; i < numberOfTokens; i++) {
                    _safeMint(_target, t + i);
                    
              }


               
   
    }


    function TeamReserve(uint _amount, address _target)public onlyOwner{
        
        require(_amount >0);
        uint256 ts = totalSupply();
        require(ts + _amount <= MAX_TOKEN);
        claimed += _amount; 

        _doMint(_amount,_target);
           
    }


    function MintBest(uint _amount)public{
        
    
       
           require(_confirmMint(_amount),"confirm");

           _doMint(_amount, _msgSender()); 
    }

    function mintTo(address to, uint size) external onlyLaunchpad{
        require(to != address(0), "can't mint to empty address");
        require(size > 0, "size must greater than zero");
        require(LAUNCH_SUPPLY + size <= LAUNCH_MAX_SUPPLY, "max supply reached");
        _doMint(size, to); 
    }

    

    function withdraw(address _beneficiary) public onlyOwner {
        uint balance = address(this).balance;
        payable(_beneficiary).transfer(balance);
    }


    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "address");
       
        _transferOwnership(newOwner);

    }
    
}   

/*                                                                   
                               %%%%%*       /%%%%*                              
                         %%%                         %%                         
                     .%%                                 %%                     
                   %%                                       %                   
                 %%                                           %                 
               %%                                               %               
             .%     @@@@@@@@@@@@@@@@@@@@@               @@@@                    
            %%      @@@                @@@             @@@         ,            
            %       @@@                  @@@         @@@                        
           %%       &&&                   &@@@     @@@              %           
           %        &&&                     @@@@ @@@                            
          ,%        &&&&&&&&&&&&&&&&&&&%%(.   @@@@@                             
           %        %%%                      @@@@@@@                            
           %        %%%                    @@@@   @@@@                          
           %%       %%%                  @@@@       @@@             %           
            %%      %%%                 @@@           @@@          %            
             %%     %%%               @@@               @@@       %             
              %%    %%%%%%%%%%%%%%%%@@@                  @@@@    %              
                %%                                             %                
                  %%                                         %                  
                    %%                                     %                    
                       %%%                             %%                       
                            %%%                   %%#                           
                                    #%%%%%%%                 

*/