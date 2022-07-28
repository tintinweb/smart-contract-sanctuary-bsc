/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

/**
 * @dev tg: ghesthauss
 */

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

contract WhitelistPresale is Ownable {
    /// @dev whitelisted users
    mapping(address => bool) whitelist;
    /**
     * @dev modifier to determine whitelisted users
     */
    modifier onlyWhitelisted() {
        require(
            isWhitelisted(_msgSender()),
            "Whitelist: User is not whitelisted!"
        );
        _;
    }

    /**
     * @dev returns whether a recepient is whitelisted or not
     * @param _recepient user address
     */
    function isWhitelisted(address _recepient) public view returns (bool) {
        return whitelist[_recepient];
    }

    /**
     * @dev adds a user to whitelist
     */
    function addWhitelist(address _recepient) external onlyOwner {
        require(
            _recepient != address(0),
            "Whitelisted address cannot be address 0!"
        );
        whitelist[_recepient] = true;
    }

    /**
     * @dev adds multiple accounts to whitelist
     * @param _recepients array of addresses of corresponding recepients
     */
    function addWhiteListMult(address[] memory _recepients) external onlyOwner {
        for (uint256 i = 0; i < _recepients.length; i++) {
            whitelist[_recepients[i]] = true;
        }
    }
}

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract YachtPresale is ReentrancyGuard, WhitelistPresale {
    address public busdAddress;
    address public tokenAddress;
    address public vaultAddress;

    // 0.04 $
    uint256 public rate = 25;

    // in busd
    uint256 public tokensBought;
    // in ERC20
    uint256 public hardcap;

    // TGE
    uint256 public cliff;
    // Set to 1 month before cliff = %10 at TGE
    uint256 public vestingStart;
    // %10 at TGE + 9 Months Vesting
    uint256 public vestingDuration = 26300000;

    // public round open on true
    bool public open = false;

    mapping(address => uint256) allocations;

    constructor(
        address _tokenAddress,
        address _busdAddress,
        address _vaultAddress
    ) {
        tokenAddress = _tokenAddress;
        busdAddress = _busdAddress;
        vaultAddress = _vaultAddress;
    }

    function setVestingSchedule(uint256 _cliff, uint256 _vestingStart)
        external
        onlyOwner
    {
        cliff = _cliff;
        vestingStart = _vestingStart;
    }

    function buyTokens(uint256 _amount) external nonReentrant {
        if (isWhitelisted(_msgSender())) {
            require(_amount != 0, "Buy amount can't be zero!");
            require(_amount < (1000 * 1e18), "You can't buy more than maximum allocation!");
            allocations[_msgSender()] = calcRate(_amount);
            tokensBought += _amount;
            IERC20(busdAddress).transferFrom(
                _msgSender(),
                vaultAddress,
                _amount
            );
        } else {
            require(open, "Public sale is not open yet!");
            require(_amount != 0, "Buy amount can't be zero!");
            require(_amount < (1000 * 1e18), "You can't buy more than maximum allocation!");
            allocations[_msgSender()] = calcRate(_amount);
            tokensBought += _amount;
            IERC20(busdAddress).transferFrom(
                _msgSender(),
                vaultAddress,
                _amount
            );
        }
    }

    function openClosePresale() external onlyOwner {
        open = !open;
    }

    function calcRate(uint256 _amount) internal view returns (uint256) {
        return _amount * rate;
    }

    function userAlloc(address _recepient) external view returns (uint256) {
        return allocations[_recepient];
    }

    function withdraw() external nonReentrant {
        require(open == false, "Sale is not over yet");
        require(block.timestamp > cliff, "Vesting has not started yet!");
        uint256 amount = _vestingSchedule(block.timestamp);
        IERC20(tokenAddress).transferFrom(vaultAddress, _msgSender(), amount);
    }

    function retrieveERC20(address _token, uint256 _amount) external onlyOwner {
        require(block.timestamp > vestingStart + vestingDuration, "You can't recover before vesting ends!");
        IERC20(_token).transfer(_msgSender(), _amount);
    }

    function _vestingSchedule(uint256 _timestamp)
        internal
        view
        returns (uint256)
    {
        if (_timestamp < vestingStart) {
            return 0;
        } else if (_timestamp > vestingStart + vestingDuration) {
            return allocations[_msgSender()];
        } else {
            return
                (allocations[_msgSender()] * (_timestamp - vestingStart)) /
                vestingDuration;
        }
    }
}