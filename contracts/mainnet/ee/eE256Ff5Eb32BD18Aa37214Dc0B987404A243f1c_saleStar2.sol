pragma solidity ^0.5.8;


//import "hardhat/console.sol";

interface NFT{
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    enum starType {st_nil,st1,st2,st3,st4,st5,st6}
    enum teamType {t_nil,t1,t2}
    function mint(address _to,string calldata _uri) external ;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
}

interface IERC20{
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

interface IREL{
    function setParent(address _ply,address _parent) external;
    function getPlyParent(address _ply) external view returns(address);
    function sonNumber(address _ply) external view returns(uint256);
}

library SafeMath {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

   
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

  
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract saleStar2{
    
    using SafeMath for *;
    
    address public owner;
    
  
    address public sNft = address(0x0);
   
    event MintNFT(uint256 _id,string uri);
    constructor(address _sNft) public{
        owner = msg.sender;        
        sNft = _sNft;
    }

    

    function setNftAddress(address _sNft)public onlyOwner{
        sNft = _sNft;
    }
    
    
    
    function batchMint(address _to, uint256 number) public onlyOwner {
        
        

        string[6] memory uris = [
        "ipfs/QmSnYCSHrqX6mkGU6wH2mVyLYNFs5spqZRqKxGV78wyvDv/metadata.json",
        "ipfs/Qma4xhXFSd3rJGfvNyrbdfH7DAojqRKMiDBqsbw4HR96gP/metadata.json",
        "ipfs/QmSFqwaidGVqDcUJkpAhFHvhAgCzoMi6EuJ92A8NyasFLG/metadata.json",
        "ipfs/QmaQ8FyK2vrDPc5Av7jGqWJEK5y9xmGYiDCBwrZ7DwxkfE/metadata.json",
        "ipfs/QmQPR9xHdALLWDk2ByfVV8u4EtXcE27ZgAzNjVdKnx2kUY/metadata.json",
        "ipfs/QmS3MuhXgzzRooSZ4p72PyQ4x8rkk6zrc1MVe5tv4HXq1T/metadata.json"
        ];

        string memory uri ='';
        
        for(uint256 i=0;i<number;i++){
            uint256 j=0;
            uint256 resultNumber;
            uint256 idex;
            resultNumber = uint256(keccak256(abi.encodePacked(blockhash(block.number),msg.sender,now,i,j)));
            idex = resultNumber %12391;
            if(idex>=0 && idex<=6099){
               uri = uris[0];
            }else if(idex>=6100 && idex <= 8223){
              uri = uris[1];
            }
            else if(idex>=8224 && idex <= 10224){
                uri = uris[2];
            }
            else if(idex>=10225 && idex <= 11378){
                uri = uris[3];
            }
            else if(idex>=11379 && idex <= 12308){
                uri = uris[4];
            }
            else if(idex>=12309 && idex <= 12391){
                uri = uris[5];

            }
            /*else if(idex>=12368 && idex <= 12379){
               uri = uris[7];

            }else if(idex>=12380 && idex<12391){
               uri = uris[8];

            }*/
            //console.log(idex,uri);
        
            mintNFTToken(_to,uri);
            
        }
    }
    
    
    
    function mintNFTToken(address _to,string memory _uri) internal returns(uint256){
        uint256 tokenID = NFT(sNft).viewTokenID();
        NFT(sNft).mint(_to,_uri);
            
        emit MintNFT(tokenID,_uri);
        return tokenID+1;
    }
    

    modifier onlyOwner(){
        require(msg.sender == owner,"only owner");
        _;
    }
    
}