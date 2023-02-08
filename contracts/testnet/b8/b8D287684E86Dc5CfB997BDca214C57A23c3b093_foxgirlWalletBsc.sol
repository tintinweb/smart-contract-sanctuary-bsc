// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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

contract foxgirlWalletBsc {
    // bsc main net
    // IRouter router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // address private foxgirlAddress = 0x599beec263FA6eA35055011967597B259FC012A4; 
    // address private priceFeedAddress = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE 

    // bsc test net
    IRouter router = IRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);     
    // IRouter router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);     
    address private foxgirlAddress = 0x887310157a7f4403d5249Bf9782dec0715a6d644;
    address private priceFeedAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;


    address private _owner = 0xBaeC52669e8c4516305cf1D4D3547AD70433C9b7;
    mapping (string =>uint256) public userDepositTotal;

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function getFoxgirlAddress() public view virtual returns (address) {
        return foxgirlAddress;
    }

    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;        
    }

    event setCreditsWithBnbEvent(string email, address wallet, uint256 amount);
    function setCreditsWithBnb(string memory userEmailAddress, uint256 _usdAmount) payable public {
        require(_usdAmount >= 15, "Minimum deposit amount must be more than $15.");
        uint256 payAmount = getBNBAmountFromUSD(_usdAmount);
        require(msg.value >= payAmount, "insufficient amount");
        userDepositTotal[userEmailAddress] += _usdAmount;
        emit setCreditsWithBnbEvent(userEmailAddress, msg.sender, _usdAmount);
    }

    event setCreditsWithFoxgirlEvent(string email, address wallet, uint256 amount);
    function setCreditsWithFoxgirl(string memory userEmailAddress, uint256 _usdAmount) public {        
        uint256 foxgirlAmount = getFoxgirlAmountFromUSD(_usdAmount);
        IERC20 asset = IERC20(foxgirlAddress);
        uint256 _tokenBalance = asset.balanceOf(msg.sender);
        require(_tokenBalance >= foxgirlAmount, "insufficient foxgirl amount");
        asset.approve(msg.sender, foxgirlAmount);
        asset.transferFrom(msg.sender, address(this), foxgirlAmount);
        userDepositTotal[userEmailAddress] += _usdAmount;
        emit setCreditsWithFoxgirlEvent(userEmailAddress, msg.sender, _usdAmount);
    }

    function getBNBAmountFromUSD(uint256 amount) public view returns(uint) {
        uint256 bnbPrice =uint256( getBNBPrice() );
        uint256 bnbAmount = uint256( (amount * 10**18 * 10**18) /bnbPrice ) ;
        return bnbAmount;
    }

    function getFoxgirlAmountFromUSD(uint256 _usdAmount) public view returns(uint) {
        uint256 payAmount = getBNBAmountFromUSD(_usdAmount);
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = foxgirlAddress;
        uint256[] memory outAmounts = router.getAmountsOut(payAmount, path);
        uint256 foxgirlAmount = outAmounts[1];
        return foxgirlAmount;
    }

    function getBNBPrice() public view returns(int) {        
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        int usd = answer * 10**10; // per 1 BNB (18 decimals)
        return usd;
    }

    event transferOwnershipEvent(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) external virtual onlyOwner() {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit transferOwnershipEvent(_owner, newOwner);
        _owner = newOwner;
    }

    function setFoxgirlAddress(address _foxgirlAddress) public onlyOwner() {
        foxgirlAddress = _foxgirlAddress;
    }

    event withdrawbyOwnerEvent(address indexed _wallet, uint256 _amount);
    function withdrawbyOwner(address payable _wallet) public onlyOwner() {
        require(_wallet != address(0), "wallet address is the zero address");
        uint256 _thisBalance = address(this).balance;
        require(_thisBalance > 0, "no bnb amount");
        _wallet.transfer(_thisBalance);
        emit withdrawbyOwnerEvent(_wallet, _thisBalance);
    }

    event withdrawFoxgirlbyOwnerEvent(address indexed _wallet, uint256 _amount);
    function withdrawFoxgirlbyOwner(address _wallet) public onlyOwner() {
        IERC20 asset = IERC20(foxgirlAddress);
        uint256 _tokenBalance = asset.balanceOf(address(this));
        require(_tokenBalance > 0, "no foxgirl amount");
        asset.transfer(_wallet, _tokenBalance);
        emit withdrawFoxgirlbyOwnerEvent(_wallet, _tokenBalance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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