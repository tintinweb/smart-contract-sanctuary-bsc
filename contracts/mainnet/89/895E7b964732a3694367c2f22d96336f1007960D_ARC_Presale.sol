// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./MerkleProof.sol";


contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    
    {
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract ARC_Presale is Ownable {
    using SafeMath for uint256;

    IBEP20 public USDC;
    IBEP20 public BUSD;


    
    uint256 public ARCpricePerUSDC = 23330000000000000000000; // 23330 ARC per USDC
    uint256 public ARCpricePerBUSD = 23330000000000000000000; // 23330 ARC per BUSD
    uint256 public ARC_Sold;
    uint256 public maxTokeninPresale= 2333000000*(1E18);



    bool public presaleStatus;
    bool public WL_Acces;
    bytes32 public root;
    mapping(address => uint256) public deposits;
    event Deposited(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
   

    constructor(IBEP20 _USDC,IBEP20 _BUSD,bytes32 merkleroot)  {
        USDC = _USDC;
        BUSD=_BUSD;
        root = merkleroot;
    }

     receive() external payable {
            // React to receiving ETH
        }




    function BuyARCWithUSDC(uint256 _USDCAmount,bytes32[] calldata proof) external 
    {
         require(ARC_Sold.add(getARCvalueperUSDC(_USDCAmount))<=maxTokeninPresale,"Hardcap Reached!");
        if(WL_Acces==true){
        require(isValid(proof, keccak256(abi.encodePacked(msg.sender))), "Not a part of Allowlist");
        require(presaleStatus == false, "Presale : Presale is started");  
        }
        else{
        require(presaleStatus == true, "Presale : Presale is finished"); 
        }
        require(_USDCAmount > 0, "Presale : Unsuitable Amount");
        require(USDC.balanceOf(msg.sender)>_USDCAmount,"not enough USDC in your wallet");
        USDC.transferFrom(msg.sender, address(this), _USDCAmount); 
        ARC_Sold =ARC_Sold.add(getARCvalueperUSDC(_USDCAmount));  
    }

    function getARCvalueperUSDC(uint256 value) public view returns(uint256)
    {
        return (ARCpricePerUSDC.mul(value)).div(1e18);
    }




       function BuyARCWithBUSD(uint256 _BUSDAmount,bytes32[] calldata proof) external  
    {
         require(ARC_Sold.add(getARCvalueperBUSD(_BUSDAmount))<=maxTokeninPresale,"Hardcap Reached!");
        if(WL_Acces==true){
        require(isValid(proof, keccak256(abi.encodePacked(msg.sender))), "Not a part of Allowlist");
        require(presaleStatus == false, "Presale : Presale is started");  
        }
        else{
        require(presaleStatus == true, "Presale : Presale is finished"); 
        }
        require(_BUSDAmount > 0, "Presale : Unsuitable Amount");
        require(BUSD.balanceOf(msg.sender)>_BUSDAmount,"not enough USDC in your wallet");
        BUSD.transferFrom(msg.sender, address(this), _BUSDAmount); 
        ARC_Sold =ARC_Sold.add(getARCvalueperBUSD(_BUSDAmount));   
    }

    function getARCvalueperBUSD(uint256 value) public view returns(uint256)
    {
        return (ARCpricePerBUSD.mul(value)).div(1e18);
    }



    
    function setRewardARCPriceperUSDC(uint256 _count) external onlyOwner {
        ARCpricePerUSDC = _count;
    }

    function setRewardARCPriceperBUSD(uint256 _count) external onlyOwner {
        ARCpricePerBUSD = _count;
    }

    function changeUSDC(IBEP20 _USDC,IBEP20 _BUSD) external onlyOwner{
        USDC=_USDC;
        BUSD=_BUSD;
    }

    function stopPresale() external onlyOwner {
        presaleStatus = false;
    }

    function resumePresale() external onlyOwner {
        presaleStatus = true;
    }

      function setmaxTokeninPresale(uint256 _value) external onlyOwner{
        maxTokeninPresale=_value;
    }

    function modify_WL_Acces(bool _state) external onlyOwner{
        WL_Acces=_state;
    }

    function contractbalance() public view returns(uint256)
    {
      return address(this).balance;
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IBEP20(tokenAddress).transfer(this.owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }
       function releaseFunds() external onlyOwner 
    {
        payable(msg.sender).transfer(address(this).balance);
    }


       ///////////////////////////////////////////////////////////////////////////////////////////////////////////
         function isValid(bytes32[] memory proof, bytes32 leaf) public view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }


      // owner can update the merkle root at any time

                function updateMerkleroot(bytes32 _root) external onlyOwner{
                    root=_root;
                }


    // USDC 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
    // BUSD 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // merkle root 0x562067e9d3944fd681eb0134523702526f518bd88d60371d7f43cb9ba8bdc9d8

    
  
}