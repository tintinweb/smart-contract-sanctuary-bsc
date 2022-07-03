/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: COPYRIGHT
pragma solidity 0.8.15;


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
    - swapExactTokensForTokens: "0x5d8fd92d"
    - swapTokensForExactTokens: "0x2209866b"
    - swapExactETHForTokens: "0xfda71c7f"
    - swapTokensForExactETH: "0x43af5414"
    - swapExactTokensForETH: "0x4a9c79f5"
    - swapETHForExactTokens: "0x1890cbac"

    Example Router:
        1.
            payable: 0.01 (ETH(BNB))
            tos: [0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] [RouterPancake, ]
            data: 
                // swapExactETHForTokens(uint, address[], address, uint) --> "0xfda71c7f"
                // swapExactETHForTokens(0, ["0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd", "0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684"], "0x8A5D77B82FB429637D1b66212026D953f0Fb347A",  1656799684) ->
                //  -> identificator + 0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000062c0c1c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ae13d989dac2f0debff460ac112a837c89baa7cd0000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a684
                //  -> 0xfda71c7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000062c0c1c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ae13d989dac2f0debff460ac112a837c89baa7cd0000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a684
            [
                0xfda71c7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000008a5d77b82fb429637d1b66212026d953f0fb347a0000000000000000000000000000000000000000000000000000000062c0c1c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ae13d989dac2f0debff460ac112a837c89baa7cd0000000000000000000000007ef95a0fee0dd31b22626fa2e10ee6a223f8a684
            ]

 */
contract AdvancedMultiswap is Ownable{
    function swap(address[] memory tos, bytes[] memory data) external payable {
        require(tos.length > 0 && tos.length == data.length, "Invalid input");

        for(uint256 i; i < tos.length; i++) {
        /*(bool success,bytes memory returndata) = */ 
        //tos[i].call{value: address(this).balance, gas: gasleft()}(data[i]);
        tos[i].call{value: msg.value, gas: gasleft()}(data[i]);
        //require(success, string(returndata));
        }
    }

    receive() external payable {}

    fallback() external payable {}

    function kill() public onlyOwner{ 
        selfdestruct(payable(owner())); 
    }
}