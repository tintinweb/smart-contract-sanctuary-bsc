/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

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
    function permit(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s) external ;
    function nonces(address owner) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20MintOrBurn is IERC20 {
    function mint(address _to, uint256 _amount) external returns (bool);
    function burn(uint256 _amount) external ;
    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);
}

interface IPriceAggregator {
    function price() external view returns(uint256);
}

contract Initializable {

  bool private initialized;
  bool private initializing;

  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;

}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address newOwner) internal {
        _owner = newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) external onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        setOwner(newOwner);
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();
    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    function pause() external onlyOwner {
        paused = true;
        emit Pause();
    }


    function unpause() external onlyOwner {
        paused = false;
        emit Unpause();
    }
}

contract Blacklistable is Ownable {
    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed _account);
    event UnBlacklisted(address indexed _account);
    event BlacklisterChanged(address indexed newBlacklister);

    modifier notBlacklisted(address _account) {
        require(
            !blacklisted[_account],
            "Blacklistable: account is blacklisted"
        );
        _;
    }

    function isBlacklisted(address _account) external view returns (bool) {
        return blacklisted[_account];
    }

    function blacklist(address _account) external onlyOwner {
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    function unBlacklist(address _account) external onlyOwner {
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }
}

contract DeoReservoir is Ownable, Pausable, Blacklistable, Initializable {
    IPriceAggregator public priceAggregator;
    IERC20MintOrBurn public inrX;
    IERC20 public busd;
    
    function initialize(IERC20MintOrBurn _inrXToken, IERC20 _busd, IPriceAggregator _aggregator, address owner) initializer external returns (bool) {
        priceAggregator = _aggregator;
        inrX = _inrXToken;
        busd   = _busd;
        setOwner(owner);
        return true;
    }

    function deposit(address user, uint256 _usdAmount)  public whenNotPaused returns (bool) {
        uint256 _busdPrice = priceAggregator.price();
        require(busd.allowance(user,address(this))>=_usdAmount,"DeoReservoir: allowance exceed");
        require(busd.balanceOf(user)>=_usdAmount,"DeoReservoir : low balance");
        uint256 _inrxAmount = _busdPrice*_usdAmount;
        busd.transferFrom(user,address(this),_usdAmount);
        inrX.mint(user,(_inrxAmount/1e18));
        return true;
    } 

    function price() public view returns (uint256) {
        return priceAggregator.price();
    } 
    
    function rescueToken(
        IERC20 tokenContract,
        address to,
        uint256 amount
    ) external onlyOwner {
        tokenContract.transfer(to, amount);
    }

    function depositWithPermit(address user, uint256 _busdAmount,uint256 deadline, uint8 v, bytes32 r , bytes32 s) external  returns (bool) {
        busd.permit(user, address(this), _busdAmount, deadline, v, r, s);
        deposit( user,  _busdAmount);
        return true;
    } 

}