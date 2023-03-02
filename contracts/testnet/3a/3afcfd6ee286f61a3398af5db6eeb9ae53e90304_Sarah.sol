/**
 *Submitted for verification at BscScan.com on 2023-03-01
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

contract Sarah is Ownable, ReentrancyGuard {
    mapping (address => bool) public allowedToken;

    uint256 public nonce;
    address public feeAddress;

    struct Package {
        uint256 price;
        uint256 request;
        bool active;
    }

    mapping (uint256 => Package) public packages;

    event Buy(int64 indexed chatID, uint256 indexed request, uint256 indexed nonce);

    constructor ( ) {
        allowedToken[0xDb29b68e38b32b88D60AB6088cd232433fc81dCf] = true;
        allowedToken[0x770b7178d35F0e49dE23025BDef668A3194657D7] = true;
        feeAddress = 0x3bEF52196aBAF96E628D7526a66E792e9449edb4;

        packages[0] = Package(100,  1000, true);
        packages[1] = Package(150,  2000, true);
        packages[2] = Package(300,  5000, true);
        packages[3] = Package(500, 10000, true);
    }

    function buyBalance(address _token, int64 _chat, uint256 _package) external nonReentrant {
        require(allowedToken[_token], "Payement method is not allowed");
        require(packages[_package].active, "Package is not active");
        
        uint256 amount = packages[_package].price * (10 ** IERC20Metadata(_token).decimals());
        require(IERC20Metadata(_token).transferFrom(msg.sender, feeAddress, amount), "Transfer failed");

        uint256 request = packages[_package].request;
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

    function setPackage(uint256 _package, uint256 _price, uint256 _request) external onlyOwner {
        packages[_package].price = _price;
        packages[_package].request = _request;
        packages[_package].active = true;
    }

    function enablePackage(uint256 _package) external onlyOwner {
        packages[_package].active = true;
    }

    function disablePackage(uint256 _package) external onlyOwner {
        packages[_package].active = false;
    }

    function getPackages() external view returns (Package[] memory) {
        Package[] memory _packages = new Package[](4);
        for (uint256 i = 0; i < 4; i++) {
            _packages[i] = Package(packages[i].price, packages[i].request, packages[i].active);
        }
        return _packages;
    }

    function claimStuckTokens(address token, uint amount) external onlyOwner {
        IERC20 ERC20token = IERC20(token);
        ERC20token.transfer(msg.sender, amount);
    }
}