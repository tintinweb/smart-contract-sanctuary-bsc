/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

interface IERC20 {

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

   
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//   _____ _____   ____  
//  |_   _|  __ \ / __ \ 
//    | | | |  | | |  | |
//    | | | |  | | |  | |
//   _| |_| |__| | |__| |
//  |_____|_____/ \____/ 
                      

                                                    
contract IDO is Ownable {
    AggregatorV3Interface internal priceFeed;

    /**
     * @dev 
     * BSC Mainnet
     * BNB/USD: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     * BTC/USD: 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
     * ETH/USD: 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e
     * WBNB: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
     *
     * BSC Testnet
     * BNB/USD: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     * BTC/USD: 0x5741306c21795FdCBb9b265Ea0255F499DFe515C
     * ETH/USD: 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
     * WBNB: 0x15C9e651b5971FeB66E19Fe9E897be6BdC3e841A
     */

    using SafeMath for uint256;

    uint256 totalMoneySpend = 0;
    uint256 cost = 0;
    uint256 public min_buy;
    uint256 public max_buy;
    uint256 public price;
    bool public onSale = false;
    mapping(address => uint256) public addressTotalAmount;
    address payable public sender;

    address private priceAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // BNB/USD Testnet
    IERC20 Token;
    
    uint256[] public percent;
    uint256[] public time;

    constructor(address payable _sender, address tokenAddress) {
        Token = IERC20(tokenAddress);
        min_buy = 1 * 10 ** 18;
        max_buy = 50 * 10 ** 18; 
        price = 30 * (10**(18 - 3));
        percent = [70, 30];
        priceFeed = AggregatorV3Interface(priceAddress);
        sender = _sender;
    }

     function updatePresalePrice(
        uint256 _min_buy,
        uint256 _max_buy,
        uint256 _price
    ) public onlyOwner {
        min_buy = _min_buy;
        max_buy = _max_buy;
        price = _price;
    }

    function getPercent(uint claimingTime) public view returns (uint256) {
        uint index = claimingTime -= 1;
        return percent[index];
    }

    function priceOfBNB() view public returns (uint) {
        (, int _price, , ,) = priceFeed.latestRoundData();
        return uint(_price).mul(1e10);
    }

    uint months = 30 days;

    function setTime(uint256 initTime) public onlyOwner{
        time = [
            initTime, initTime + 3 * months
        ];
    }
     
    function getCost(uint _amount) public view returns (uint256) {
        return _amount.mul(priceOfBNB()).div(10**18);
    }

    // Presale
    function buyToken(uint256 _amount) public payable {
        require(onSale, "Pre-sales is not available now");
        require(msg.value >= _amount, "insufficient funds");

        cost = getCost(_amount);
        totalMoneySpend = cost + addressTotalAmount[msg.sender];
        
        require(
            totalMoneySpend <= max_buy,
            "Total amount bigger than max buy amount"
        );
        require(
            totalMoneySpend >= min_buy,
            "Total amount smaller than min buy amount"
        );
        addressTotalAmount[msg.sender] += cost;
    }

    function checkAddressMaxClaim(address _address) public view returns (uint256) {
        return addressTotalAmount[_address];
    }

     mapping (address => mapping (uint256 => bool)) isClaimed;

    function getTokenReceive(address _address) public view returns (uint256) {
        return (addressTotalAmount[_address] * 10**uint256(Token.decimals()) / price);
    }

     // Claim token
    function claimToken(uint256 claimingTime) public {
        uint index = claimingTime -= 1;
        require(block.timestamp > time[index], "Please wait until claiming day");
        require(!isClaimed[msg.sender][index], "You had claimed this time");

        uint256 amount = getTokenReceive(msg.sender) * percent[index] / 100;
        require(
            Token.balanceOf(sender) >= amount,
            "Pool is out of Token, please try again later"
        );
        
        Token.transferFrom(sender, msg.sender, amount);
        isClaimed[msg.sender][index] = true;
    }

    function checkAddressClaim(address _address)public view returns (bool, bool){
        return  (isClaimed[_address][0], isClaimed[msg.sender][1]);
    }

    function setOnSale(bool _onSale) external onlyOwner {
        onSale = _onSale;
    }

    function getOnSale() public view returns (bool) {
        return onSale;
    }

    receive() external payable{}
    function withdrawBNB() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken() external onlyOwner {
        Token.transfer(owner(),address(this).balance);
    }


     function setManualTime(uint256[] memory times ) public onlyOwner {
        time = times;
    }

    function getClaimTime() public view returns(uint256, uint256) {
        return (time[0], time[1]);
    }

    function getSender() public view returns (address) {
        return sender;
    }

    function setSender(address payable _sender) public onlyOwner {
        sender = _sender;
    }

     function changeToken(address tokenAddress) public onlyOwner {
        Token = IERC20(tokenAddress);
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

}