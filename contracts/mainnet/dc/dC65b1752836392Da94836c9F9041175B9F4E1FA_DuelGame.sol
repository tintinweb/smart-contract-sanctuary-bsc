// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IDEXRouter {
    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external pure returns(uint256[] memory);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external pure returns(uint256[] memory);
}

contract DuelGame is Ownable {
  address public BUSD = block.chainid==56 ? 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 : 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
  address public WBNB = block.chainid==56 ? 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c : 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
  uint256 public duelCounter;
  uint256 public invitePeriod = block.chainid==56 ? 6 hours : 3 minutes;
  uint256 public duelLength = block.chainid==56 ? 24 hours : 5 minutes;
  struct Duel {
    address token;
    address wallet1;
    address wallet2;
    uint256 depositAmount;
    uint256 price1;
    uint256 price2;
    uint256 resultPrice;
    uint8 categoryIndex;
    uint256 createdTime;
    uint8 status;
  }

  mapping(uint256 => Duel) public duels;
  uint256[] public amountArr = [1, 5, 10, 25, 50, 100, 250, 500, 1000, 2000];
  address public royaltyWallet1;
  address public royaltyWallet2;
  address public royaltyWallet3;
  uint256 public fee1;
  uint256 public fee2;
  uint256 public fee3;
  IDEXRouter router;
  address public botAddress;
  bool public paused;
  mapping(address => mapping(uint8=> bool)) public walletToCategory;

  bool public disableTokenHold;
  uint256 public holdAmount;
  address public duelToken;
  mapping(address => bool) public whitelistedWallets;
  modifier onlyBot() {
    require(msg.sender == botAddress || msg.sender == owner(), "not bot");
    _;
  }
  modifier notPaused() {
    require(paused==false, "paused");
    _;
  }
  modifier onlyTokenHolder {
    require(IERC20(duelToken).balanceOf(msg.sender)>=holdAmount || disableTokenHold || whitelistedWallets[msg.sender], "not whitelisted");
    _;
  }
  constructor () {
    router = IDEXRouter(block.chainid==56 ? 0x10ED43C718714eb63d5aA57B78B54704E256024E : 0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    royaltyWallet1 = msg.sender;
    royaltyWallet2 = msg.sender;
    royaltyWallet3 = msg.sender;
    fee1 = 7;
    fee2 = 8;
    fee3 = 6;
    botAddress = msg.sender;
  }
 
  function isContract(address addr) private returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

  function createDuel(address _token, uint8 _categoryIndex, uint256 _price1) external notPaused {
    require(isContract(_token), "not token");
    require(_categoryIndex<=9, "out of range");
    require(!walletToCategory[msg.sender][_categoryIndex], "already create for this division");
    uint256 amount = getDepositAmount(_token, _categoryIndex);
    duels[duelCounter] = Duel(_token, msg.sender, address(0), amount, _price1, 0, 0, _categoryIndex, block.timestamp, 1); 
    duelCounter++;
    IERC20(_token).transferFrom(msg.sender, address(this), amount);
    walletToCategory[msg.sender][_categoryIndex] = true;
  }
  
  function createDuelForBNB(uint8 _categoryIndex, uint256 _price1) external payable notPaused {
    require(_categoryIndex<=9, "out of range");
    uint256 amount = getDepositAmount(WBNB, _categoryIndex);
    require(msg.value == amount, "not matching amount");
    require(!walletToCategory[msg.sender][_categoryIndex], "already create for this division");
    duels[duelCounter] = Duel(WBNB, msg.sender, address(0), amount, _price1, 0, 0, _categoryIndex, block.timestamp, 1); 
    duelCounter++;
    walletToCategory[msg.sender][_categoryIndex] = true;
  }

  function cancelDuel(uint256 duelId) external {
    require(duels[duelId].wallet1==msg.sender, "not matching wallet");
    require(duels[duelId].status == 1, "not matching status");
    if(duels[duelId].token==WBNB) {
      payable(duels[duelId].wallet1).transfer(duels[duelId].depositAmount);
    } else {
      IERC20(duels[duelId].token).transferFrom(address(this), duels[duelId].wallet1, duels[duelId].depositAmount);
    }
    duels[duelId].depositAmount = 0;
    duels[duelId].status = 4;
    walletToCategory[duels[duelId].wallet1][duels[duelId].categoryIndex] = false;
  }

  function joinDuel(uint256 duelId, uint256 _price2) external notPaused {
    require(block.timestamp<=duels[duelId].createdTime+invitePeriod, "expired duel");
    require(msg.sender!=duels[duelId].wallet1, "same wallet");
    require(duels[duelId].status==1, "not matching status");
    duels[duelId].wallet2 = msg.sender;
    uint256 amount = getDepositAmount(duels[duelId].token, duels[duelId].categoryIndex);
    duels[duelId].depositAmount += amount;
    duels[duelId].price2 = _price2;
    duels[duelId].status = 2;
    IERC20(duels[duelId].token).transferFrom(msg.sender, address(this), amount);
  }
  
  function joinDuelForBNB(uint256 duelId, uint256 _price2) external payable notPaused {
    require(block.timestamp<=duels[duelId].createdTime+invitePeriod, "expired duel");
    require(msg.sender!=duels[duelId].wallet1, "same wallet");
    uint256 amount = getDepositAmount(duels[duelId].token, duels[duelId].categoryIndex);
    require(msg.value==amount, "not matching amount");
    require(WBNB==duels[duelId].token, "not matching token"); //checking if its' for BNB
    require(duels[duelId].status==1, "not matching status");
    duels[duelId].wallet2 = msg.sender;
    duels[duelId].depositAmount += amount;
    duels[duelId].price2 = _price2;
    duels[duelId].status = 2;
  }
  function finishDuel(uint256 duelId) external {
    require(duels[duelId].status == 2 && duels[duelId].resultPrice==0, "condition not meet");
    require(block.timestamp>=duels[duelId].createdTime+duelLength, "not reached time");
    address[] memory path = new address[](2);
    path[0] = duels[duelId].token;
    path[1] = BUSD;
    duels[duelId].resultPrice = router.getAmountsOut(IERC20(duels[duelId].token).decimals(), path)[1];
    uint256 diff1 = duels[duelId].resultPrice >= duels[duelId].price1 ? duels[duelId].resultPrice - duels[duelId].price1 : duels[duelId].price1 - duels[duelId].resultPrice;
    uint256 diff2 = duels[duelId].resultPrice >= duels[duelId].price2 ? duels[duelId].resultPrice - duels[duelId].price2 : duels[duelId].price2 - duels[duelId].resultPrice;
    uint256 amount1 = duels[duelId].depositAmount*fee1/100;
    uint256 amount2 = duels[duelId].depositAmount*fee2/100;
    uint256 amount3 = duels[duelId].depositAmount*fee3/100;
    uint256 restAmount = duels[duelId].depositAmount - amount1 - amount2 - amount3;
    if(diff1>diff2) { // wallet2 wins
      if(duels[duelId].token==WBNB) {
        payable(royaltyWallet1).transfer(amount1);
        payable(royaltyWallet2).transfer(amount2);
        payable(royaltyWallet3).transfer(amount3);
        payable(duels[duelId].wallet1).transfer(restAmount);
      } else {
        IERC20(duels[duelId].token).transfer(royaltyWallet1, amount1);
        IERC20(duels[duelId].token).transfer(royaltyWallet2, amount2);
        IERC20(duels[duelId].token).transfer(royaltyWallet3, amount3);
        IERC20(duels[duelId].token).transfer(duels[duelId].wallet1, restAmount); 
      }
    } else if(diff1<diff2) { // wallet1 wins 
      if(duels[duelId].token==WBNB) {
        payable(royaltyWallet1).transfer(amount1);
        payable(royaltyWallet2).transfer(amount2);
        payable(royaltyWallet3).transfer(amount3);
        payable(duels[duelId].wallet2).transfer(restAmount);
      } else {
        IERC20(duels[duelId].token).transfer(royaltyWallet1, amount1);
        IERC20(duels[duelId].token).transfer(royaltyWallet2, amount2);
        IERC20(duels[duelId].token).transfer(royaltyWallet3, amount3);
        IERC20(duels[duelId].token).transfer(duels[duelId].wallet2, restAmount); 
      }
    } else { // When duel is a draw,
      if(duels[duelId].token==WBNB) {
        payable(duels[duelId].wallet1).transfer(duels[duelId].depositAmount/2);
        payable(duels[duelId].wallet2).transfer(duels[duelId].depositAmount/2);
      } else {
        IERC20(duels[duelId].token).transfer(duels[duelId].wallet1, duels[duelId].depositAmount/2); 
        IERC20(duels[duelId].token).transfer(duels[duelId].wallet2, duels[duelId].depositAmount/2); 
      }
    }
    duels[duelId].status = 5; // finshed duel
    walletToCategory[duels[duelId].wallet1][duels[duelId].categoryIndex] = false;
    walletToCategory[duels[duelId].wallet2][duels[duelId].categoryIndex] = false;
  }

  function getDepositAmount(address _token, uint256 _categoryIndex) public view returns(uint256) {
    address[] memory path = new address[](2);
    path[0] = BUSD;
    path[1] = _token;
    return router.getAmountsOut(amountArr[_categoryIndex] * IERC20(_token).decimals(), path)[1];
  }
  function setBot(address _addr) external onlyOwner {
    botAddress = _addr;
  }
  function setPause(bool _paused) external onlyOwner {
    paused = _paused;
  }
  
  function withdrawBNB() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }
  function updateInvitationPeriod(uint256 _invitationPeriod, uint256 _duelLength) external onlyOwner {
    invitePeriod = _invitationPeriod;
    duelLength = _duelLength;
  }
  
  function manageDuelTokenHold(bool _disable, uint256 _holdAmount) external onlyOwner {
    disableTokenHold = _disable;
    holdAmount = _holdAmount;
  }

  function manageWhitelistedWallets(address[] memory _wallets, bool _whitelist) external onlyOwner {
    for(uint256 i = 0; i< _wallets.length; i++) {
      whitelistedWallets[_wallets[i]] = _whitelist;
    }
  }

  function setDuelToken(address _token) external onlyOwner {
    duelToken = _token;
  }
  
  receive() external payable{}
}