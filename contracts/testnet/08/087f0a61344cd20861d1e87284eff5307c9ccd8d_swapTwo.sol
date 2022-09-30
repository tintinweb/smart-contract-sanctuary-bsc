/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract swapTwo is Ownable, ReentrancyGuard {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }

    //默认
    address public tokenA = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public tokenB = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public oneA;
    uint256 public oneB;

    //
    uint256 public tokenA2B = 10;
    //
    uint256 public minTokenA;
    uint256 public maxTokenA;
    //
    uint256 public minTokenB;
    uint256 public maxTokenB;

    event WithdrawToken(
        address indexed token,
        address indexed to,
        uint256 value
    );
    event SwapAB(
        address indexed from,
        uint256 indexed amountIn,
        uint256 indexed amountOut
    );
    event SwapBA(
        address indexed from,
        uint256 indexed amountIn,
        uint256 indexed amountOut
    );

event UpdateRate(uint256 oldAmount, uint256 newAmount);
event UpdateConfigA(uint256 minAmount,uint256 maxAmount);
event UpdateConfigB(uint256 minAmount,uint256 maxAmount);
    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _a2bPrice
    ) {
        _init(_tokenA, _tokenB);
        tokenA2B = _a2bPrice;
    }

    function _init(address _tokenA, address _tokenB) internal {
        tokenA = _tokenA;
        tokenB = _tokenB;
        uint8 decimalsA = IERC20(_tokenA).decimals();
        uint8 decimalsB = IERC20(_tokenB).decimals();
        oneA = 10**uint256(decimalsA);
        oneB = 10**uint256(decimalsB);
    }
    function testSetToken(address _tokenA, address _tokenB)external onlyOwner {
         _init(_tokenA, _tokenB);
    }
    //
    function setPrice(uint256 a2b) external onlyOwner {
        emit UpdateRate(tokenA2B,a2b);
        tokenA2B = a2b;
        
    }

    function setConfigA(uint256 _minA, uint256 _maxA) external onlyOwner {
        minTokenA = _minA;
        maxTokenA = _maxA;
       emit UpdateConfigA(minTokenA,maxTokenA);
    }

    function setConfigB(uint256 _minB, uint256 _maxB) external onlyOwner {
        minTokenB = _minB;
        maxTokenB = _maxB;

       emit UpdateConfigB(minTokenB,maxTokenB);
    }

    //
    function swapA2B(uint256 _amountA) external nonReentrant {
        require(_amountA >= minTokenA, "minA");
        require(_amountA <= maxTokenA, "maxA");
        uint256 amountB = getAmountB(_amountA);
        safeTransferFrom(tokenA, msg.sender, address(this), _amountA);
        safeTransfer(tokenB, msg.sender, amountB);
        emit SwapAB(msg.sender, _amountA, amountB);
    }

    function swapB2A(uint256 _amountB) external nonReentrant {
        require(_amountB >= minTokenB, "minB");
        require(_amountB <= maxTokenB, "maxB");
        uint256 amountA = getAmountA(_amountB);
        safeTransferFrom(tokenB, msg.sender, address(this), _amountB);
        safeTransfer(tokenA, msg.sender, amountA);
        emit SwapBA(msg.sender, _amountB, amountA);
    }

    function getAmountB(uint256 _amountA) public view returns (uint256) {
        return (_amountA * tokenA2B) / oneB;
    }

    function getAmountA(uint256 _amountB) public view returns (uint256) {
        return (_amountB  * oneA) / tokenA2B;
    }

    function withdrawToken(
        address _token,
        address _to,
        uint256 _v
    ) public onlyOwner {
        safeTransfer(_token, _to, _v);
        emit WithdrawToken(_token, _to, _v);
    }
}