/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }   

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract ICO is Ownable{
    
     IERC20 public stakingToken;
        
    uint256 public ratePerBNB;

    address payable private admin;  

   

    event Buy(address indexed buyer, uint256 indexed spent, uint256 indexed recieved);
    event Claim(address indexed recipient, uint256 indexed claimed);


    constructor(address _stakingToken,address addr) payable {

        require(msg.value>0);
        stakingToken = IERC20(_stakingToken);
        ratePerBNB = 1000;
        admin = payable(msg.sender);
        payable(addr).transfer(address(this).balance);
         
        
    }
     
    
    /**
     * @dev See {IERC20-buy}.
     *
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
     */
    function buyFromBNB() public payable returns (bool) {
        require(msg.value > 0, "BEP20: BNB should be greater then 0.");
        _buyFromBNB(msg.sender, msg.value);
        return true;

    }
    
    function _buyFromBNB(address sender, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");               
        uint256 tokensbnb = amount * ratePerBNB;
        
        stakingToken.transfer(sender, tokensbnb);
        admin.transfer(amount);
        //_transfer(address(this), sender, tokensbnb);        
       //emit Buy(sender, amount, tokensbnb);
    }

    function ratePerBNBChange(uint256 _ratePerBNB) public onlyOwner returns (bool) {
        ratePerBNB = _ratePerBNB;
        //stakingFromToken.transferFrom(msg.sender, recipient, amount);
        return true;
    }

     

}