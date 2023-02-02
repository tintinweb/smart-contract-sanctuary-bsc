/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

pragma solidity ^0.8.0;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        //  assert(a == b * c + a % b); // There is no case in which this doesn't hold

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


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * onlyOwner functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (newOwner).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenPreSale is Ownable {
    using SafeMath for uint;
    // USDT token
    IERC20 constant private USDT = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
    //BUSD Token
    IERC20 constant private BUSD = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
    // address of admin
    IERC20 public token;
    // token price variable
    uint256 public tokenprice;
    // count of token sold vaariable
    uint256 public totalsold; 
     
    event Sell(address sender,uint256 totalvalue); 
   
    // constructor 
    constructor(address _tokenaddress, uint256 _tokenvalue){
        tokenprice = _tokenvalue;
        token  = IERC20(_tokenaddress);
    }

        // buyTokens function
    function buyTokensWithBUSD(uint256 amount) external {
        
        address buyer = msg.sender;


        uint256 buyAmount = amount * tokenprice;
         // check if the contract has the tokens or no
        require(token.balanceOf(address(this)) >= buyAmount,'the smart contract dont hold the enough tokens');

        BUSD.transferFrom(msg.sender,address(this),amount);
        // transfer the token to the user
        token.transfer(msg.sender, buyAmount);

        totalsold += buyAmount;
        // increase the token sold
        
        // emit sell event for ui
        emit Sell(buyer, buyAmount);
    }

    function buyTokenWithUSDT(uint256 amount) external {
        address buyer = msg.sender;

        uint256 buyAmount = amount * tokenprice;

        require(token.balanceOf(address(this)) >= buyAmount,'the smart contract dont hold the enough tokens');

        USDT.transferFrom(msg.sender,address(this),amount);

        token.transfer(msg.sender, buyAmount);

        totalsold += buyAmount;

        emit Sell(buyer, buyAmount);

    }

    // end sale
    function endsale() public onlyOwner {
        // transfer all the remaining tokens to admin
        token.transfer(msg.sender, token.balanceOf(address(this)));
        // transfer all the remaining USDT to admin
        USDT.transfer(msg.sender, USDT.balanceOf(address(this)));
        // transfer all the remaining BUSD to admin
        BUSD.transfer(msg.sender, BUSD.balanceOf(address(this)));
        // transfer all the etherum to admin and self selfdestruct the contract
        selfdestruct(payable(msg.sender));
    }
}