// SPDX-License-Identifier: Apache-2.0



/*
        ███████╗ █████╗  ██████╗ ██╗     ███████╗
        ██╔════╝██╔══██╗██╔════╝ ██║     ██╔════╝
        █████╗  ███████║██║  ███╗██║     █████╗
        ██╔══╝  ██╔══██║██║   ██║██║     ██╔══╝
        ███████╗██║  ██║╚██████╔╝███████╗███████╗
        ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝
*/

pragma solidity ^0.8.10;

import "./Interface/IEAGLENFT.sol";
import "./Interface/utils/Strings.sol";
import "./Interface/access/Ownable.sol";
import "./Interface/token/ERC20/ERC20.sol";
import "./Interface/pancake/IPancakeRouter02.sol";
import "./Interface/pancake/IPancakeFactory.sol";
import "./Interface/pancake/IPancakePair.sol";
import "./Wrap.sol";

/// @custom:security-contact EAGLE TEAM
contract EAGLE is ERC20, Ownable {
    using Strings for uint256;
    address public MarketingWallet;

    // @EAGLENFTAddress NFT address
    // @usdt usdt address
    // @pancakeSwapV2Router pancakeSwap router address
    // @pancakeSwapV2Pair pancakeSwap pair address(EAGLE/USDT)(POOL ADDRESS)
    IEAGLENFT public EAGLENFTAddress;
    IERC20 public immutable usdt;
    IPancakeRouter02 public immutable pancakeSwapV2Router;
    IPancakePair public immutable pancakeSwapV2Pair;

    uint256 private coolingTime = 5 minutes;
    // @whitelist Free service charge for white list
    mapping(address => bool) public whitelist;
    Wrap public wrap;
    uint256 private txFee;

    // Tax payment switch or not
    bool public swapAndLiquifyEnabled;

    constructor(address _usdtAddress, address _marketingWallet,address _eagleNft) ERC20("EAGLE", "EGL") {
        _mint(_msgSender(), 10000000 * 10**decimals());
        MarketingWallet = _marketingWallet;
        EAGLENFTAddress = IEAGLENFT(_eagleNft);
        transferOwnership(MarketingWallet);
        usdt = IERC20(_usdtAddress);
        IPancakeRouter02 _pancakeSwapv2Route = IPancakeRouter02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        address _pancakeV2Pair = IPancakeFactory(_pancakeSwapv2Route.factory())
        .createPair(address(this), address(usdt));
        pancakeSwapV2Router = _pancakeSwapv2Route;
        pancakeSwapV2Pair = IPancakePair(_pancakeV2Pair);
        wrap = new Wrap(address(usdt),address(this));
        whitelist[MarketingWallet] = true;
        whitelist[address(this)] = true;
        usdt.approve(address(pancakeSwapV2Router), ~uint256(0));
        _approve(address(this), address(pancakeSwapV2Router), ~uint256(0));
    }

    // @addWhitelist add whitelist Address and Free service charge for white list
    // onlyOwner add whitelist
    function addWhitelist(address _newEntry) external onlyOwner {
        whitelist[_newEntry] = true;
    }

    // @removeWhitelist remove whitelist Address and Free service charge for white list
    // onlyOwner remove whitelist
    function removeWhitelist(address _newEntry) external onlyOwner {
        require(whitelist[_newEntry], "Previous not in whitelist");
        whitelist[_newEntry] = false;
    }

    // @updateSwapAndLiquifupdateSwapAndLiquifyEnabledyEnabled Control tax payment switch
    // Must wait until the end of the first liquidity addition Can be opened
    function updateSwapAndLiquifupdateSwapAndLiquifyEnabledyEnabled(bool status) external onlyOwner{
        swapAndLiquifyEnabled = status;
    }

    // @addLiquidityUseUsdt add liquidity use usdt and EAGLE to EAGLE/USDT POOL in pancakeSwap
    // tokenA:EAGLE     tokenB:USDT
    // pancakeSwap: addLiquidity used token A and B，The liquidity provider is address(this)
    function addLiquidityUseUsdt(uint256 tokenAmount, uint256 usdtAmount,address to)
    private
    {
        pancakeSwapV2Router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            usdtAmount,
            0,
            0,
            to,
            block.timestamp
        );
    }

    // @swapTokensForUsdt swap EAGLE to USDT (pancakeSwap EAGLE/USDT POOL)
    // tokenA:EAGLE     tokenB:USDT
    // pancakeSwap: swap EAGLE to token USDT,The user is address(this)
    // only to is address(this)
    //TODO
    function swapTokensForUsdt(uint256 tokenAmount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        // make the swap
        pancakeSwapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of token
            path,
            address(wrap),
            block.timestamp + 360
        );
        wrap.withdraw();
    }

    // @swapUsdtAndLiquify swap USDT to EAGLE and add liquidity to EAGLE/USDT POOL
    // tokenA:EAGLE     tokenB:USDT
    // pancakeSwap: swap a half EAGLE to USDT,and addLiquidity EAGLE and USDT to pancakePool
    function swapUsdtAndLiquify(uint256 tokenAmount) private {
        uint256 half = tokenAmount * 8 / 100;
        uint256 otherHalf = tokenAmount - half;
        uint256 balance = usdt.balanceOf(address(this));
        swapTokensForUsdt(otherHalf);
        uint256 newBalance = usdt.balanceOf(address(this))-balance;
        uint256 backflow = newBalance / 10;
        addLiquidityUseUsdt(half, backflow,address(this));
    }

    //  to receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    //  withdraw BNB
    function emergencyBNBWithdraw() public onlyOwner {
        (bool success, ) = address(owner()).call{ value: address(this).balance }("");
        require(success, "Address: unable to send value, may have reverted");
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 trsAmount = amount;
        // Ordinary users need to wait for the opening transaction button after adding liquidity
        if ( swapAndLiquifyEnabled &&  !whitelist[from] &&  !(from == address(this) && to == address(pancakeSwapV2Pair))) {
            // 2.8% is Service Charge
            uint256 feeAmount = (amount * 28) / 1000;
            if (feeAmount > 0){
                super._transfer(from, address(this), feeAmount);
                if(to == address(pancakeSwapV2Pair)){
                    dealWithTxFee(feeAmount + txFee);
                    txFee = 0;
                }else{
                    txFee = feeAmount;
                }
            }
            trsAmount = amount - feeAmount;
        }
        super._transfer(from, to, trsAmount);
    }

    // @usdtDistribute When the contract balance reaches 50 usdt, air drop usdt will be distributed
    function dealWithTxFee(uint256 tokenAmount) private {
        uint256 fee = (tokenAmount * 14) / 100;
        uint256 NFTRewrd = tokenAmount - fee;
        super._transfer(address(this), MarketingWallet, fee);
        swapUsdtAndLiquify(NFTRewrd);
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance >= 500 * 10**18) {
            usdtDistribute(usdtBalance);
        }
    }

    // @usdtDistribute When the contract balance reaches 50 usdt, air drop usdt will be distributed
    // 2.8% is Service Charge
    // 0.4% (14%) => Marking Wallet; 0.4% (14%) swapUsdtAndLiquify（backflow to EAGLE/USDT POOL）
    // 0.5 (18%)% => tigerEagleard Holders ; 1.5% (54%) => PhoenixEagleCard Holders
    // When the contract balance reaches 50 usdt, air drop usdt will be distributed
    function usdtDistribute(uint256 usdtBalance) private {
        (address[] memory holdAddress,uint[] memory types) = EAGLENFTAddress.getNFTConfig();
        (uint128 tigerEaglecardNum,uint128 PhoenixEagleCardNum) = EAGLENFTAddress.getNFTCardNumber();
        uint256 tigerOwnerPart = (usdtBalance * 25) / 100 / tigerEaglecardNum;
        uint256 phoenixOwnerPart = (usdtBalance * 75) / 100 / PhoenixEagleCardNum;
        for (uint256 i = 0; i < types.length; i++) {
            if(types[i] == 0){
                usdt.transfer(holdAddress[i], tigerOwnerPart);
            }else if(types[i] == 1){
                usdt.transfer(holdAddress[i], phoenixOwnerPart);
            }
        }
    }


    // @receiveNFTrewards Receive the award of this NFT
    function receiveNFTrewards(uint256 _tokenId) external {
        uint256 NFTCreateTime = EAGLENFTAddress.getNFTCreateTime(_tokenId);
        uint256 nftCreationTimeInterval = block.timestamp - NFTCreateTime;
        uint256 nowReceivingBatch = nftCreationTimeInterval / coolingTime;
        require(
            _msgSender() == EAGLENFTAddress.ownerOf(_tokenId),
            "you not owner this NFT"
        );
        require(
            nftCreationTimeInterval > coolingTime,
            "this nft create time not lagger 30 days,please wait!!!"
        );
        uint256 coinReward;
        if (nowReceivingBatch > 12) {
            nowReceivingBatch = 12;
        }
        for (uint256 i = 1; i <= nowReceivingBatch; i++) {
            if (EAGLENFTAddress.getNFTDraw(_tokenId, i) == false) {
                coinReward += getNFTThisMonthReward(_tokenId, i);
                EAGLENFTAddress.setNFTConfigReceiveOnlyEAGLETOKEN(_tokenId, i);
            }
        }
        super._transfer(address(this), msg.sender, coinReward);
    }

    // @getReward Check how much the NFT can charge
    function getReward(uint256 _tokenId) public view returns (uint256) {
        uint256 NFTCreateTime = EAGLENFTAddress.getNFTCreateTime(_tokenId);
        uint256 nftCreationInterval = block.timestamp - NFTCreateTime;
        uint256 nowReceivingBatch = nftCreationInterval / coolingTime;
        uint256 coinReward;
        if (nowReceivingBatch > 12) {
            nowReceivingBatch = 12;
        }
        for (uint256 i = 1; i <= nowReceivingBatch; i++) {
            if (EAGLENFTAddress.getNFTDraw(_tokenId, i) == false) {
                coinReward += getNFTThisMonthReward(_tokenId, i);
            }
        }
        return coinReward;
    }

    // @getNFTThisMonthReward Query how much the NFT can collect in the first month
    function getNFTThisMonthReward(uint256 _tokenId, uint256 monthId)
    public
    view
    returns (uint256)
    {
        require(monthId > 0 && monthId <= 12);
        uint256 coinRewardNow;
        if (EAGLENFTAddress.getNFTEAGLESerial(_tokenId) == 0) {
            if (monthId <= 6) {
                coinRewardNow = 200 * 10**decimals();
            } else {
                coinRewardNow = 100 * 10**decimals();
            }
        } else if (EAGLENFTAddress.getNFTEAGLESerial(_tokenId) == 1) {
            if (monthId <= 6) {
                coinRewardNow = 100 * 10**decimals();
            } else {
                coinRewardNow = 50 * 10**decimals();
            }
        }
        return coinRewardNow;
    }

    // @getNFTPoolDates Get the NFT pool data
    function getNFTPoolDates(uint256 _tokenId)
    external
    view
    returns (string memory)
    {
        string memory cardName = EAGLENFTAddress.tokenType(_tokenId);
        string memory name = string(
            abi.encodePacked(cardName, " EAGLE NFT#", _tokenId.toString())
        );
        uint256 nftCreationInterval = block.timestamp -
        EAGLENFTAddress.getNFTCreateTime(_tokenId);
        uint256 nowReceivingBatch = nftCreationInterval / coolingTime;
        uint256 drawMonth;
        uint256 availableQuantity = getReward(_tokenId);
        for (uint256 i = 1; i <= nowReceivingBatch; i++) {
            if (EAGLENFTAddress.getNFTDraw(_tokenId, i) == true) {
                drawMonth += 1;
            }
        }
        string memory thisMonthReceiv;
        bool receiveOrNot = EAGLENFTAddress.getNFTDraw(
            _tokenId,
            nowReceivingBatch
        );
        if (receiveOrNot == true){
            thisMonthReceiv = "true";
        }else{
            thisMonthReceiv = "false";
        }
        uint256 nextCollectCountDown = coolingTime -
        (nftCreationInterval % coolingTime);

        string memory description = string(
            abi.encodePacked(
                '[{"DrawMonth":',
                drawMonth.toString(),
                ',"NotDrawMonth":',
                (12 - drawMonth).toString(),
                ',"availableQuantity":',
                availableQuantity.toString(),
                ',"ReceiveOrNot":',
                thisMonthReceiv,
                ',"NextCollectCountDown":',
                nextCollectCountDown.toString(),
                '}],'
            )
        );

        return
        string(
            abi.encodePacked(
                '{"token_id":',
                _tokenId.toString(),
                ',"name":"',
                name,
                ',"description":',
                description,
                '"}'
            )
        );
    }
}

// SPDX-License-Identifier: Apache-2.0



pragma solidity ^0.8.0;

import "./token/ERC721/IERC721.sol";

interface IEAGLENFT is IERC721 {
    // @initEagleToken This function can only be used once
    // The purpose is to load EagleToken address
    function initEagleToken(address _EagleToken) external;

    // @setNFTConfigReceiveOnlyEAGLETOKEN Set NFTConfig Receive Only EAGLETOKEN
    // Receive the reward of the specified month
    // Only after receiving rewards can they be sold in the market
    function setNFTConfigReceiveOnlyEAGLETOKEN(uint256 _tokenId, uint256 _batch)
        external;

    // @getNFTCreateTime Query appoint NFT create time
    function getNFTCreateTime(uint256 tokenId) external view returns (uint256);

    // @getNFTDraw Query Whether the reward has been received in the specified month
    function getNFTDraw(uint256 tokenId, uint256 _batch)
        external
        view
        returns (bool);

    // @tokenType Query the type of an NFT
    function tokenType(uint256 tokenId) external view returns (string memory);

    // @getNFTEAGLESerial get nft type
    function getNFTEAGLESerial(uint256 tokenId) external view returns (uint256);

    // @getNFTCardNumber Query the respective quantity of the current two NFTs
    function getNFTCardNumber()
        external
        pure
        returns (uint128 tigerEaglecardNum, uint128 PhoenixEagleCardNum);

    // @tokenDescribe Query the Describe of an NFT
    function tokenDescribe(uint256 tokenId)
        external
        view
        returns (string memory);

    function getNFTConfig()external view returns (address[] memory, uint[] memory);
}

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: Apache-2.0



import "./Interface/token/ERC20/IERC20.sol";

pragma solidity ^0.8.10;

contract Wrap {
    address public eagle;
    IERC20 public usdt;

    constructor(address _usdt,address _eagle) {
        eagle = _eagle;
        usdt = IERC20(_usdt);
    }

    function withdraw() public {
        require(msg.sender == eagle, "only eagle can withdraw");
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(eagle, usdtBalance);
        }
    }

}

// SPDX-License-Identifier: Apache-2.0



pragma solidity >=0.6.2;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: Apache-2.0



pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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