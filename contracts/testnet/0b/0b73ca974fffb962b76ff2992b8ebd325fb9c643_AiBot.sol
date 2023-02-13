/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IERC20 {
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
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract AiBot is Ownable, ReentrancyGuard {
    mapping (address => bool) public allowedToken;
    
    uint256 public requestPerDollar;
    uint256 public nonce;
    address public feeAddress;
    event Buy(int64 indexed chatID, uint256 indexed request, uint256 indexed nonce);

    constructor (
        uint256 _requestPerDollar,
        address[] memory _allowedTokens,
        address _feeAddress
    ) {
        requestPerDollar = _requestPerDollar;
        for (uint256 i = 0; i < _allowedTokens.length; i++) {
            allowedToken[_allowedTokens[i]] = true;
        }
        feeAddress = _feeAddress;
    }

    function buyBalance(address _token, int64 _chat, uint256 _amount) external nonReentrant {
        require(allowedToken[_token], "AiBot: Token not allowed");
        IERC20Metadata token = IERC20Metadata(_token);
        require(_amount >= 100 , "AiBot: Minimum buy is $100");
        uint256 amount = _amount * (10 ** token.decimals());
        require(token.transferFrom(msg.sender, feeAddress, amount), "AiBot: Transfer failed");
        uint256 request = _amount * requestPerDollar;
        emit Buy(_chat, request, nonce);
        nonce++;
    }

    function addAllowedToken(address _token) external onlyOwner {
        allowedToken[_token] = true;
    }

    function removeAllowedToken(address _token) external onlyOwner {
        allowedToken[_token] = false;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
    }

    function setRequestPerDollar(uint256 _requestPerDollar) external onlyOwner {
        requestPerDollar = _requestPerDollar;
    }

    function claimStuckTokens(address token, uint amount) external onlyOwner {
        IERC20 ERC20token = IERC20(token);
        ERC20token.transfer(msg.sender, amount);
    }
}