/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/Incrementor.sol

pragma solidity ^0.8.0;


interface CallProxy{
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags

    ) payable external;
}


interface IMultichainRouter {
    function anySwapOutUnderlying(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

    function anySwapOut(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

    function anySwapOutNative(
        address token,
        address to,
        uint256 toChainID
    ) external payable;

    function wNATIVE() external returns (address);
}


contract Incrementor {  

    address private multichainRouter;
    address constant anyCallProxy = 0xC10Ef9F491C9B59f936957026020C321651ac078;
    address private owner;
    event LogCallIn(address srcServer, uint256 srcChain, address receiver, address token, uint256 amount, uint256 currentBalance);

    mapping(address => mapping(uint256 => address)) private tokenPeer;
    mapping(uint256 => address) private serverPeer;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor (address _owner, address _multichainRouter) public {
        owner = _owner;
        multichainRouter = _multichainRouter;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function setTokenPeer(address token, uint256 chain, address desToken) public {
        tokenPeer[token][chain] = desToken;
    }

    function getTokenPeer(address token, uint256 chain) public view returns (address) {
        return (tokenPeer[token][chain]);
    }

    function setServerPeer(uint256 chainId, address peer) public {
        serverPeer[chainId] = peer;
    }

    function getServerPeer(uint256 chainId) public view returns (address) {
        return (serverPeer[chainId]);
    }

    function setMultichainRouter(address _multichainRouter) public {
        multichainRouter = _multichainRouter;
    }

    function getMultichainRouter() public view returns (address) {
        return (multichainRouter);
    }

    function callOut(
        uint256 serverChainId,
        address anyToken,
        address originalToken,
        address receiver,
        uint256 amount,
        uint256 flag,
        address contractAddressTo
    ) public payable {
        bytes memory message = abi.encode(
            address(this),
            block.chainid,
            receiver,
            tokenPeer[anyToken][serverChainId],
            amount
        );

        IERC20(originalToken).approve(multichainRouter, amount);
            // replace tokenAddress with anyTokenAddress (if mapping found) and call ERC20 asset bridge function
        IMultichainRouter(multichainRouter).anySwapOutUnderlying(
            anyToken,
            contractAddressTo,
            amount,
            serverChainId
        );

        // CallProxy(anyCallProxy).anyCall{value: msg.value}(
        //         serverPeer[serverChainId],
        //         message,
        //         serverChainId,
        //         flag, // flags
        //         ""
        //     );

        CallProxy(anyCallProxy).anyCall{value: msg.value}(
            serverPeer[serverChainId],

            // sending the encoded bytes of the string msg and decode on the destination chain
            message,

            // 0x as fallback address because we don't have a fallback function
            address(0),

            // chainid of polygon
            serverChainId,

            // Using 0 flag to pay fee on destination chain
            flag
            );
    }

    function anyExecute(bytes memory _data) external returns (bool success, bytes memory result){
        (address contratSender, uint256 srcChain, address receiver, address token, uint256 amount) = 
        abi.decode(
            _data,
            (address, uint256, address, address, uint256)
        );

        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        if (currentBalance >= 0){
            IERC20(token).transfer(receiver, currentBalance);
        }

        emit LogCallIn(contratSender, srcChain, receiver, token, amount, currentBalance);
    }

    function withdrawFunds(address token, address receiver) public onlyOwner {
        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(receiver, currentBalance);
    }
}