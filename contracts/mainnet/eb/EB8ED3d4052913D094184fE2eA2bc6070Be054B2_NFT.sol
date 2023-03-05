/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }
    }


    interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

interface IERC1155 is IERC165 {
  
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

   
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
function mintBatch2(
        address[] memory accounts,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;
function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
        

    }
    
 
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token   public USDT    = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
        IERC1155     public NFT     = IERC1155  (0xF567681527CF371D78e2FBA81c2d60aAD560732c);
 
        address public _owner;
        address  _Manager; 
  
        function Convert(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000000000);
        }
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }
        modifier only_Manager() {
            require(msg.sender == _Manager, "Permission denied"); _;
        }
 
    function transferMship(address newadd) public onlyOwner {
        require(newadd != address(0));
        _Manager = newadd;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    receive() external payable {}  
}
  
contract NFT  is Base{
 
    mapping(uint256 => uint256) public NFTPrice; 
 
    function setNFTPrice(uint256 ID,uint256 Price ) public  onlyOwner {
        NFTPrice[ID] = Price;
    }
  
 
 
    function BuyNFT(uint256 ID) public    {
        USDT.transferFrom(msg.sender, address(this), NFTPrice[ID]);
        NFT.mint(msg.sender,ID,1,"0x00");
    } 
 
    function wic(address _to,address _contract,uint256 amount) public  onlyOwner {
        Erc20Token(_contract).transfer(_to, amount);
    }

    constructor()
    public {
        _owner = 0x94fD3817270F368D563D477B917F5769eABbBd97; 
      }
}