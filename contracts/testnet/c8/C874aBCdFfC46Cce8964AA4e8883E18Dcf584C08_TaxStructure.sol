/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

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

contract TaxStructure is Ownable {
    uint256 public feeDecimal = 2;
    address public routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    string public tax1Name = "Marketing Tax";
    address public tax1Wallet = 0x6DFcd4331b0d86bfe0318706C76B832dA4C03C1B;
    uint256 public tax1BuyConfig = 200;
    uint256 public tax1SellConfig = 200;

    string public tax2Name = "Charity Tax";
    address public tax2Wallet = 0xa56891cfBd0175E6Fc46Bf7d647DE26100e95C78;
    uint256 public tax2BuyConfig = 200;
    uint256 public tax2SellConfig = 200;

    string public tax3Name;
    address public tax3Wallet;
    uint256 public tax3BuyConfig;
    uint256 public tax3SellConfig;

    string public tax4Name;
    address public tax4Wallet;
    uint256 public tax4BuyConfig;
    uint256 public tax4SellConfig;
  
    string public tokenTaxName;
    address public tokenTaxWallet;
    uint256 public tokenTaxBuyConfig;
    uint256 public tokenTaxSellConfig;

    address public burnAddress;
    uint256 public burnTaxBuyConfig;
    uint256 public burnTaxSellConfig;
  
    address public lpTokenHolder = 0x9036464e4ecD2d40d21EE38a0398AEdD6805a09B;
    uint256 public liquidityTaxBuyConfig = 200;
    uint256 public liquidityTaxSellConfig = 200;

    string public customTaxName;

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

    constructor () public {}

    // buy amounts
    function tax1BuyAmount (address _address) external view returns (uint256) {
      return tax1BuyConfig;
    }
    function tax2BuyAmount (address _address) external view returns (uint256) {
      return tax2BuyConfig;
    }
    function tax3BuyAmount (address _address) external view returns (uint256) {
      return tax3BuyConfig;
    }
    function tax4BuyAmount (address _address) external view returns (uint256) {
      return tax4BuyConfig;
    }
    function tokenTaxBuyAmount (address _address) external view returns (uint256) {
      return tokenTaxBuyConfig;
    }
    function burnTaxBuyAmount (address _address) external view returns (uint256) {
      return burnTaxBuyConfig;
    }
    function liquidityTaxBuyAmount (address _address) external view returns (uint256) {
      return liquidityTaxBuyConfig;
    }

    // sell sell amounts
    function tax1SellAmount (address _address) external view returns (uint256) {
      return tax1SellConfig;
    }
    function tax2SellAmount (address _address) external view returns (uint256) {
      return tax2SellConfig;
    }
    function tax3SellAmount (address _address) external view returns (uint256) {
      return tax3SellConfig;
    }
    function tax4SellAmount (address _address) external view returns (uint256) {
      return tax4SellConfig;
    }
    function tokenTaxSellAmount (address _address) external view returns (uint256) {
      return tokenTaxSellConfig;
    }
    function burnTaxSellAmount (address _address) external view returns (uint256) {
      return burnTaxSellConfig;
    }
    function liquidityTaxSellAmount (address _address) external view returns (uint256) {
      return liquidityTaxSellConfig;
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
      uint256 _oldBuyAmount = tax1BuyConfig;
      uint256 _oldSellAmount = tax1SellConfig;

      tax1Name = _name;
      tax1Wallet = _wallet;
      tax1BuyConfig = _buyAmount;
      tax1SellConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax1Name,
        tax1Wallet,
        tax1BuyConfig,
        tax1SellConfig
      );
    }

    function setTax2 (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      string memory _oldName = tax2Name;
      address _oldWallet = tax2Wallet;
      uint256 _oldBuyAmount = tax2BuyConfig;
      uint256 _oldSellAmount = tax2SellConfig;

      tax2Name = _name;
      tax2Wallet = _wallet;
      tax2BuyConfig = _buyAmount;
      tax2SellConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax2Name,
        tax2Wallet,
        tax2BuyConfig,
        tax2SellConfig
      );
    }

    function setTax3 (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner  {
      string memory _oldName = tax3Name;
      address _oldWallet = tax3Wallet;
      uint256 _oldBuyAmount = tax3BuyConfig;
      uint256 _oldSellAmount = tax3SellConfig;

      tax3Name = _name;
      tax3Wallet = _wallet;
      tax3BuyConfig = _buyAmount;
      tax3SellConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax3Name,
        tax3Wallet,
        tax3BuyConfig,
        tax3SellConfig
      );
    }

    function setTax4 (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      string memory _oldName = tax4Name;
      address _oldWallet = tax4Wallet;
      uint256 _oldBuyAmount = tax4BuyConfig;
      uint256 _oldSellAmount = tax4SellConfig;

      tax4Name = _name;
      tax4Wallet = _wallet;
      tax4BuyConfig = _buyAmount;
      tax4SellConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tax4Name,
        tax4Wallet,
        tax4BuyConfig,
        tax4SellConfig
      );
    }

    function setTokenTax (string memory _name, address _wallet, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      string memory _oldName = tokenTaxName;
      address _oldWallet = tokenTaxWallet;
      uint256 _oldBuyAmount = tokenTaxBuyConfig;
      uint256 _oldSellAmount = tokenTaxSellConfig;

      tokenTaxName = _name;
      tokenTaxWallet = _wallet;
      tokenTaxBuyConfig = _buyAmount;
      tokenTaxSellConfig = _sellAmount;

      emit TaxUpdated(
        _oldName,
        _oldWallet,
        _oldBuyAmount,
        _oldSellAmount,
        tokenTaxName,
        tokenTaxWallet,
        tokenTaxBuyConfig,
        tokenTaxSellConfig
      );
    }

    function setLiquidityTax (address _lpTokenHolder, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      address _oldLpTokenHolder = lpTokenHolder;
      uint256 _oldBuyAmount = liquidityTaxBuyConfig;
      uint256 _oldSellAmount = liquidityTaxSellConfig;

      lpTokenHolder = _lpTokenHolder;
      liquidityTaxBuyConfig = _buyAmount;
      liquidityTaxSellConfig = _sellAmount;

      emit TaxUpdated(
        'Liquidity Tax',
        _oldLpTokenHolder,
        _oldBuyAmount,
        _oldSellAmount,
        'Liquidity Tax',
        lpTokenHolder,
        liquidityTaxBuyConfig,
        liquidityTaxSellConfig
      );
    }

    function setBurnTax (address _burnAddress, uint256 _buyAmount, uint256 _sellAmount) external onlyOwner {
      address _oldBurnAddress = burnAddress;
      uint256 _oldBuyAmount = burnTaxBuyConfig;
      uint256 _oldSellAmount = burnTaxSellConfig;

      burnAddress = _burnAddress;
      burnTaxBuyConfig = _buyAmount;
      burnTaxSellConfig = _sellAmount;

      emit TaxUpdated(
        'Burn Tax',
        _oldBurnAddress,
        _oldBuyAmount,
        _oldSellAmount,
        'Burn Tax',
        burnAddress,
        burnTaxBuyConfig,
        burnTaxSellConfig
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

    function setFeeDecimal (uint256 _newDecimal) external onlyOwner {
      uint256 _oldDecimal = feeDecimal;
      feeDecimal = _newDecimal;
      
      emit FeeDecimalUpdated(
        _oldDecimal,
        feeDecimal
      );
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