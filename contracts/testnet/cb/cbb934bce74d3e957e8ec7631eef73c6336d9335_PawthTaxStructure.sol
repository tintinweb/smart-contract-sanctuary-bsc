/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC1155 {
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
}

/**
 * @dev Interface of the Pawthereum contract.
 */
interface Pawthereum {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function _isPurrEnabled() external view returns (bool);

    function charityWallet() external view returns (address);
    function marketingWallet() external view returns (address);
    function stakingWallet() external view returns (address);
    function lpTokenHolder() external view returns (address);

    function _feeDecimal() external view returns (uint256);
    function _burnFee() external view returns (uint256);
    function _charityFee() external view returns (uint256);
    function _liquidityFee() external view returns (uint256);
    function _stakingFee() external view returns (uint256);
    function _marketingFee() external view returns (uint256);
    function _taxFee() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PawthTaxStructure is Ownable {
    using SafeMath for uint256;

    Pawthereum public pawthereum;

    // will respect nft1155 holding benefits if on and ignore if off
    bool public respect1155 = true;
    // the address of the nft that needs to be held to reap nft1155HoldFactor benefits
    address public nft1155BenefitAddress = 0x6de1863F4f408D6D2ffC34a83308A386D8316b19;
    // the id of the 1155 nft that needs to be held to reap nft1155HoldFactor benefits
    uint256 public nft1155BenefitId = 0;
    // 5000 is a halving of pawswap fees if holding erc-1155 nft
    uint256 public nft1155HoldFactor = 5000;
    // will respect purr factors if on and ignore purr if off
    bool public respectPurr = true;
    // 5000 is a halving of pawswap fees for buys if purr is on
    uint256 public purrBuyFactor = 5000;
    // 20000 is doubling of pawswap fees for sells if purr is on
    uint256 public purrSellFactor = 20000;

    uint256 public feeDecimal = 2;
    address public routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    string public tax1Name = "Marketing Tax";
    address public tax1Wallet = 0x6DFcd4331b0d86bfe0318706C76B832dA4C03C1B;
    uint256 public tax1BuyAmountConfig = 200;
    uint256 public tax1SellAmountConfig = 200;

    string public tax2Name = "Charity Tax";
    address public tax2Wallet = 0xa56891cfBd0175E6Fc46Bf7d647DE26100e95C78;
    uint256 public tax2BuyAmountConfig = 200;
    uint256 public tax2SellAmountConfig = 200;

    string public tax3Name = "Buy Back and Burn Tax";
    address public tax3Wallet = 0x5a185c361dd4573f1Bb8044d5D8275e25831b53e;
    uint256 public tax3BuyAmountConfig = 0;
    uint256 public tax3SellAmountConfig = 0;

    // tax 4 will not respect the purr by design in case we ever need that
    string public tax4Name = "";
    address public tax4Wallet = 0x9036464e4ecD2d40d21EE38a0398AEdD6805a09B;
    uint256 public tax4BuyAmountConfig = 0;
    uint256 public tax4SellAmountConfig = 0;
  
    string public tokenTaxName = "";
    address public tokenTaxWallet = 0x445664D66C294F49bb55A90d3c30BCAB0F9502A9;
    uint256 public tokenTaxBuyAmountConfig = 0;
    uint256 public tokenTaxSellAmountConfig = 0;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public burnTaxBuyAmountConfig = 0;
    uint256 public burnTaxSellAmountConfig = 0;
  
    address public lpTokenHolder = 0x9036464e4ecD2d40d21EE38a0398AEdD6805a09B;
    uint256 public liquidityTaxBuyAmountConfig = 200;
    uint256 public liquidityTaxSellAmountConfig = 200;

    string public customTaxName = "Extra Charity Tax";

    event TaxUpdated(
        string oldName,
        address oldWallet,
        uint256 oldBuyAmount,
        uint256 oldSellAmount,
        string newName,
        address newWallet,
        uint256 newBuyAmount,
        uint256 newSellAmount
    );

    event CustomTaxNameUpdated(
        string oldName,
        string newName
    );

    event RouterUpdated(
        address oldRouter,
        address newRouter
    );

    event FeeDecimalUpdated(
        uint256 oldDecimal,
        uint256 newDecimal
    );

    constructor (address _pawthereum) public {
      pawthereum = Pawthereum(_pawthereum);
    }

    function holds1155 (address _address) internal view returns (bool) {
      return IERC1155(nft1155BenefitAddress).balanceOf(_address, nft1155BenefitId) > 0;
    }

    // marketing buy fee
    function tax1BuyAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax1BuyAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrBuyFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // marketing sell fee
    function tax1SellAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax1SellAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrSellFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // charity buy fee
    function tax2BuyAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax2BuyAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrBuyFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // charity sell fee
    function tax2SellAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax2SellAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrSellFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }
  
    // tax buy fee
    function tax3BuyAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax3BuyAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrBuyFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // tax sell fee
    function tax3SellAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax3SellAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrSellFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // tax buy fee
    function tax4BuyAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax4BuyAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrBuyFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // tax sell fee
    function tax4SellAmount(address _address) external view returns (uint256) {
        uint256 _fee = tax4SellAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrSellFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // staking buy fee
    function tokenTaxBuyAmount(address _address) external view returns (uint256) {
        uint256 _fee = tokenTaxBuyAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrBuyFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // staking sell fee
    function tokenTaxSellAmount(address _address) external view returns (uint256) {
        uint256 _fee = tokenTaxSellAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrSellFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // liquidity buy fee
    function liquidityTaxBuyAmount(address _address) external view returns (uint256) {
        uint256 _fee = liquidityTaxBuyAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrBuyFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // liquidity sell fee
    function liquidityTaxSellAmount(address _address) external view returns (uint256) {
        uint256 _fee = liquidityTaxSellAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrSellFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // burn buy fee
    function burnTaxBuyAmount(address _address) external view returns (uint256) {
        uint256 _fee = burnTaxBuyAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrBuyFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    // burn sell fee
    function burnTaxSellAmount(address _address) external view returns (uint256) {
        uint256 _fee = burnTaxSellAmountConfig;
        if (respect1155 && holds1155(_address)) {
          _fee = _fee.mul(nft1155HoldFactor).div((10**(feeDecimal + 2)));
        }
        if (respectPurr && pawthereum._isPurrEnabled()) {
          return _fee.mul(purrSellFactor).div((10**(feeDecimal + 2)));
        }
        return _fee;
    }

    function setRouterAddress (address _newRouterAddress) external onlyOwner {
      address _oldRouter = routerAddress;
      routerAddress = _newRouterAddress;

      emit RouterUpdated(
        _oldRouter,
        routerAddress
      );
    }

    function setTax1 (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      string memory _oldName = tax1Name;
      address _oldWallet = tax1Wallet;
      uint256 _oldBuyAmount = tax1BuyAmountConfig;
      uint256 _oldSellAmount = tax1SellAmountConfig;

      tax1Name = _name;
      tax1Wallet = _wallet;
      tax1BuyAmountConfig = _buyAmount;
      tax1SellAmountConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax1Name,
        tax1Wallet,
        tax1BuyAmountConfig,
        tax1SellAmountConfig
      );
    }

    function setTax2 (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      string memory _oldName = tax2Name;
      address _oldWallet = tax2Wallet;
      uint256 _oldBuyAmount = tax2BuyAmountConfig;
      uint256 _oldSellAmount = tax2SellAmountConfig;

      tax2Name = _name;
      tax2Wallet = _wallet;
      tax2BuyAmountConfig = _buyAmount;
      tax2SellAmountConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax2Name,
        tax2Wallet,
        tax2BuyAmountConfig,
        tax2SellAmountConfig
      );
    }

    function setTax3 (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner  {
      string memory _oldName = tax3Name;
      address _oldWallet = tax3Wallet;
      uint256 _oldBuyAmount = tax3BuyAmountConfig;
      uint256 _oldSellAmount = tax3SellAmountConfig;

      tax3Name = _name;
      tax3Wallet = _wallet;
      tax3BuyAmountConfig = _buyAmount;
      tax3SellAmountConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax3Name,
        tax3Wallet,
        tax3BuyAmountConfig,
        tax3SellAmountConfig
      );
    }

    function setTax4 (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      string memory _oldName = tax4Name;
      address _oldWallet = tax4Wallet;
      uint256 _oldBuyAmount = tax4BuyAmountConfig;
      uint256 _oldSellAmount = tax4SellAmountConfig;

      tax4Name = _name;
      tax4Wallet = _wallet;
      tax4BuyAmountConfig = _buyAmount;
      tax4SellAmountConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax4Name,
        tax4Wallet,
        tax4BuyAmountConfig,
        tax4SellAmountConfig
      );
    }

    function setTokenTax (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      string memory _oldName = tokenTaxName;
      address _oldWallet = tokenTaxWallet;
      uint256 _oldBuyAmount = tokenTaxBuyAmountConfig;
      uint256 _oldSellAmount = tokenTaxSellAmountConfig;

      tokenTaxName = _name;
      tokenTaxWallet = _wallet;
      tokenTaxBuyAmountConfig = _buyAmount;
      tokenTaxSellAmountConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tokenTaxName,
        tokenTaxWallet,
        tokenTaxBuyAmountConfig,
        tokenTaxSellAmountConfig
      );
    }

    function setLiquidityTax (address _lpTokenHolder, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      address _oldLpTokenHolder = lpTokenHolder;
      uint256 _oldBuyAmount = liquidityTaxBuyAmountConfig;
      uint256 _oldSellAmount = liquidityTaxSellAmountConfig;

      lpTokenHolder = _lpTokenHolder;
      liquidityTaxBuyAmountConfig = _buyAmount;
      liquidityTaxSellAmountConfig = _sellAmount;

      emit TaxUpdated(
        'Liquidity Tax',
        _oldLpTokenHolder,
        _oldBuyAmount,
        _oldSellAmount,
        'Liquidity Tax',
        lpTokenHolder,
        liquidityTaxBuyAmountConfig,
        liquidityTaxSellAmountConfig
      );
    }

    function setBurnTax (address _burnAddress, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      address _oldBurnAddress = burnAddress;
      uint256 _oldBuyAmount = burnTaxBuyAmountConfig;
      uint256 _oldSellAmount = burnTaxSellAmountConfig;

      burnAddress = _burnAddress;
      burnTaxBuyAmountConfig = _buyAmount;
      burnTaxSellAmountConfig = _sellAmount;

      emit TaxUpdated(
        'Burn Tax',
        _oldBurnAddress,
        _oldBuyAmount,
        _oldSellAmount,
        'Burn Tax',
        burnAddress,
        burnTaxBuyAmountConfig,
        burnTaxSellAmountConfig
      );
    }

    function setCustomTaxName (string memory _name) external onlyOwner {
      string memory _oldName = customTaxName;
      customTaxName = _name;

      emit CustomTaxNameUpdated(
        _oldName,
        customTaxName
      );
    }

    function setPawthereum (address _pawthereum) external onlyOwner {
      pawthereum = Pawthereum(_pawthereum);
    }

    function setFeeDecimal (uint256 _newDecimal) external onlyOwner {
      uint256 _oldDecimal = feeDecimal;
      feeDecimal = _newDecimal;
      
      emit FeeDecimalUpdated(
        _oldDecimal,
        feeDecimal
      );
    }

    function setNft1155Config (bool _respect1155, uint256 _nft1155HoldFactor, address _nftAddress, uint _nftId) external onlyOwner {
      respect1155 = _respect1155;
      nft1155BenefitAddress = _nftAddress;
      nft1155BenefitId = _nftId;
      nft1155HoldFactor = _nft1155HoldFactor;
    }

    function setPurrConfig (bool _respectPurr, uint256 _purrBuyFactor, uint256 _purrSellFactor) external onlyOwner {
      respectPurr = _respectPurr;
      purrBuyFactor = _purrBuyFactor;
      purrSellFactor = _purrSellFactor;
    }

    function withdrawEthToOwner (uint256 _amount) external onlyOwner {
        payable(_msgSender()).transfer(_amount);
    }

    function withdrawTokenToOwner(address tokenAddress, uint256 amount) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance >= amount, "Insufficient token balance");

        IERC20(tokenAddress).transfer(_msgSender(), amount);
    }

    receive() external payable {}
}