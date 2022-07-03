/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: COPYRIGHT
pragma solidity 0.8.15;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

//import "@openzeppelin/contracts/utils/Context.sol";
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

//import "@openzeppelin/contracts/access/Ownable.sol";
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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
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


/**
    Function selectors of PancakeRouter
    - swapExactTokensForTokens: ""
    - swapTokensForExactTokens: ""
    - swapExactETHForTokens: ""
    - swapTokensForExactETH: ""
    - swapExactTokensForETH: ""
    - swapETHForExactTokens: ""
 */
contract AdvancedMultiswap is Ownable{

    /**
    
        Example Router:
        1. swapExactETHForTokens(0,  [WBNB, USDT], owner(), GMT Sunday October 8 2023 10:20:02 PM )
            payable: 0.01 (ETH(BNB))
            tos: [0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] [RouterPancake]
            data: 
                // swapExactETHForTokens(uint, address[], address, uint) --> 0x7ff36ab5
                // swapExactETHForTokens(0, ["0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd", "0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684"], "0x8A5D77B82FB429637D1b66212026D953f0Fb347A",  1656799684) ->
                //  -> identificator + 0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000065232b120000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ae13d989dac2f0debff460ac112a837c89baa7cd0000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a684
                //  -> 0x7ff36ab50x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000065232b120000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ae13d989dac2f0debff460ac112a837c89baa7cd0000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a684
            [
                0x7ff36ab5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000065232b120000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ae13d989dac2f0debff460ac112a837c89baa7cd0000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a684
            ]

        Resources: https://youtu.be/B62nrJ5Qmko
    */
    function swapPayable(address[] memory tos, bytes[] memory data, uint availableGas) external payable onlyOwner{
        require(tos.length > 0 && tos.length == data.length, "Invalid input");

        for(uint256 i; i < tos.length; i++) {
            (bool success, bytes memory returndata) = tos[i].call{value: msg.value, gas: availableGas}(data[i]);
            //tos[i].call{value: address(this).balance, gas: gasleft()}(data[i]);
            //tos[i].call{value: msg.value, gas: gasleft()}(data[i]);
            require(success, string(returndata));
        }
    }

    /**
    
        1. swapExactTokensForTokens(500000000000000000 (0.5USDT), 0, [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7], owner(), GMT Sunday October 8 2023 10:20:02 PM)
            tos: [0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] [RouterPancake]
            data: 
                // swapExactTokensForTokens(uint,uint,address[],address,uint) --> 0x38ed1739
                // ABI data ->
                //  -> identificator + 0x00000000000000000000000000000000000000000000000006f05b59d3b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000065232b1200000000000000000000000000000000000000000000000000000000000000020000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a68400000000000000000000000078867bbeef44f2326bf8ddd1941a4439382ef2a7
                //  -> 0x38ed17390x00000000000000000000000000000000000000000000000006f05b59d3b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000065232b1200000000000000000000000000000000000000000000000000000000000000020000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a68400000000000000000000000078867bbeef44f2326bf8ddd1941a4439382ef2a7
            [
                0x38ed173900000000000000000000000000000000000000000000000006f05b59d3b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000065232b1200000000000000000000000000000000000000000000000000000000000000020000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a68400000000000000000000000078867bbeef44f2326bf8ddd1941a4439382ef2a7
            ]

            Remember to run the runApproval(...) function:
                [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684] [USDT(pancake)]
                [0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] [PANCAKE_ROUTER]

            Also Remember to approve (outside of this contract, i.e. bscscan) that the input token can be spent by this contract.
            115792089237316195423570985008687907853269984665640564039457584007913129639935
     */
    function swap(address[] memory tos, bytes[] memory data, uint availableGas) external onlyOwner{
        require(tos.length > 0 && tos.length == data.length, "Invalid input");

        // This function is not payable, so it is not suitable for swaps that has ETH as input, but it is usable for
        // swaps which has ERC20 tokens as inputs. The important thing here is that before the swap the ERC20 token 
        // must be placed in this contract so that it can be taken by the router (having the two main 
        // approvals mentioned in the description of this function done of course)
        // This important requisite make my wonder if I should add here the .transferFrom code or
        // if this should be done beforehand in other external logic... probably it depends if this
        // function is exclusively focused on down SWAPS with ERC20 tokens as input, always. If this is the case, then yes,
        // adding the .transferFrom to this function is optimal. But having an external logic adding ERC20 tokens to this
        // contract automatically is also Ok if managed correctly, but for now I will hardcoded it.

        // The first token of the path is supposed to be the input token and no more input tokens are needed. (maybe I am wrong)

        // As the source token is ERC20 I have to make a transfer from the wallet to this 
        // contract, as it is the wallet that has the source token that I will use to buy.
        (uint amountIn, uint amountOutMin, address[] memory path, address receiver, uint deadline) = abi.decode(data[0], (uint,uint,address[],address,uint));
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        for(uint256 i; i < tos.length; i++) {
            (bool success, bytes memory returndata) = tos[i].call{gas: availableGas}(data[i]);
            require(success, string(returndata));
        }
    }

    /**
        Handy function that approves the addresses_being_approved to be spended by the spender_addresses that is placed
        in the same array position as the addresses_being_approved, 1:1 match
        Everything is approved with maximum allowance: 115792089237316195423570985008687907853269984665640564039457584007913129639935
        The good thing of running this function is that the owner is this contract, so we are allowing the spender_addresses to use 
        the address_being_approved on behalf of the owner (this contract)

        NOTE: Max amount of addresses that can be approved in a single call in this function is type(uint8).max, which is 256 address

        It is specially used with the Router approach, when using the Pairs to execute the swaps it is not needed
        - For tradeExactTokenForToken:
            [0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684] [USDT(pancake), USDT(pancake)]
            [0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3, 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] [PANCAKE_ROUTER, PANCAKE_ROUTER]
     */
    function runApproval(address[] calldata addresses_being_approved, address[] calldata spender_addresses) external onlyOwner {
        require(addresses_being_approved.length == spender_addresses.length, "Both addresses_being_approved and spender_addresses musth have same length");
        require(addresses_being_approved.length >= 1, "Length of spender_addresses needs to be 1 at least");
        require(spender_addresses.length >= 1, "Length of spender_addresses needs to be 1 at least");
        
        for (uint8 index = 0; index < spender_addresses.length; index++) {
            IERC20(addresses_being_approved[index]).approve(
                address(spender_addresses[index]),
                type(uint256).max
            ); 
        }
    }

    // Returns the BNB(ETH) that is in this contract to the owner(sender actually, but as this function has onlyOwner modified it will be always de owner)
    function returnETH() external onlyOwner {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use: https://solidity-by-example.org/sending-ether
        (bool sent, bytes memory data) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "Failed to return Ether");
    }

    // Returns the specific token balance that is in this contract to the owner(sender actually, but as this function has onlyOwner modified it will be always de owner)
    function returnToken(address address_token) external onlyOwner {
        // Call returns a boolean value indicating success or failure.
        // I think it is more appropiate to use .transfer than .transferFrom
        bool sent = IERC20(address_token).transfer(msg.sender, IERC20(address_token).balanceOf(address(this)));
        require(sent, "Failed to return token");
    }

    receive() external payable {}

    fallback() external payable {}

    function kill() public onlyOwner{ 
        selfdestruct(payable(owner())); 
    }
}