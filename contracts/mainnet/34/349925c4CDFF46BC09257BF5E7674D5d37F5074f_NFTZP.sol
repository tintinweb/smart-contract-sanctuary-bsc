/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-15
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
        assert(b > 0);  
            uint256 c = a / b;
        assert(a == b * c + a % b); 
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
        IERC1155 public NFT     = IERC1155  (0xB6c2C5b7d7Bf5646f2Afc6Ca04c150eBd0107ef2);
         address public _owner;
        address  _Manager; 
        address USDTaddress; 
 
   
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
   

    function transferMship(address newadd) public onlyOwner {
        require(newadd != address(0));
        _Manager = newadd;
    }


    function transferUship(address newadd) public onlyOwner {
        require(newadd != address(0));
        USDTaddress = newadd;
    }

   
    modifier onlyManager() {
        require(msg.sender == _Manager, "Permission denied Manager"); _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

  

    
    receive() external payable {}  
}
contract NFTZP is Base{
    uint256 public level;

    function withdrawNFT(address playeraddress,uint256 withdrawNFTNum ) public  onlyManager()  returns(uint256)   {
         
        NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(1),_asSingletonArray(withdrawNFTNum),"0x00");

    }
    function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
        return array;
    }
 
   

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        require(element != 0, "0"); 
        array[0] = element;
        return array;
    }

    function Withdrawal(uint256 Count) public payable   {
        require(msg.value == level);
 
    }

    function setlevel(uint256 Count) public onlyOwner{
        level = Count;
    }

    constructor()
    public {
        _owner = msg.sender; 
     }

    
  function withdrawBNB() public onlyOwner {
    address payable owner = address(uint160(_owner));
    owner.transfer(address(this).balance);
  }
}