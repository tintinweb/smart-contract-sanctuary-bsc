// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./interfaces/IAdapterBsc.sol";

contract HedgepieAdapterManagerBsc is Ownable {
    struct AdapterInfo {
        address addr;
        string name;
        address stakingToken;
        bool status;
    }

    // Info of each adapter
    AdapterInfo[] public adapterInfo;
    // investor address
    address public investor;

    event AdapterAdded(address strategy);
    event AdapterRemoveed(address strategy);
    event InvestorUpdated(address investor);

    /**
     * @notice Throws if adapter is not active
     */
    modifier onlyActiveAdapter(address _adapter) {
        bool isExisted = false;
        for (uint256 i; i < adapterInfo.length; i++) {
            if (
                adapterInfo[i].addr == address(_adapter) &&
                adapterInfo[i].status
            ) {
                isExisted = true;
                break;
            }
        }
        require(isExisted, "Error: Adapter is not active");
        _;
    }

    /**
     * @notice Throws if called by any account other than the investor.
     */
    modifier onlyInvestor() {
        require(msg.sender == investor, "Error: caller is not investor");
        _;
    }

    /**
     * @notice Get a list of adapters
     */
    function getAdapters() external view returns (AdapterInfo[] memory) {
        return adapterInfo;
    }

    /**
     * @notice Get a list of adapters
     */
    function getAdapterInfo(address _adapterAddr)
        external
        view
        returns (
            address adapterAddr,
            string memory name,
            address stakingToken,
            bool status
        )
    {
        for (uint256 i; i < adapterInfo.length; i++) {
            if (adapterInfo[i].addr == _adapterAddr && adapterInfo[i].status) {
                adapterAddr = adapterInfo[i].addr;
                name = adapterInfo[i].name;
                stakingToken = adapterInfo[i].stakingToken;
                status = adapterInfo[i].status;

                break;
            }
        }
    }

    /**
     * @notice Get strategy address of adapter contract
     * @param _adapter  adapter address
     */
    function getAdapterStrat(address _adapter)
        external
        view
        onlyActiveAdapter(_adapter)
        returns (address adapterStrat)
    {
        adapterStrat = IAdapterBsc(_adapter).strategy();
    }

    // ===== Owner functions =====
    /**
     * @notice Add adapter
     * @param _adapter  adapter address
     */
    /// #if_succeeds {:msg "Adapter not set correctly"} adapterInfo.length == old(adapterInfo.length) + 1;
    function addAdapter(address _adapter) external onlyOwner {
        require(_adapter != address(0), "Invalid adapter address");

        adapterInfo.push(
            AdapterInfo({
                addr: _adapter,
                name: IAdapterBsc(_adapter).name(),
                stakingToken: IAdapterBsc(_adapter).stakingToken(),
                status: true
            })
        );

        emit AdapterAdded(_adapter);
    }

    /**
     * @notice Remove adapter
     * @param _adapterId  adapter id
     * @param _status  adapter status
     */
    /// #if_succeeds {:msg "Status not updated"} adapterInfo[_adapterId].status == _status;
    function setAdapter(uint256 _adapterId, bool _status) external onlyOwner {
        require(_adapterId < adapterInfo.length, "Invalid adapter address");

        adapterInfo[_adapterId].status = _status;
    }

    /**
     * @notice Set investor contract
     * @param _investor  investor address
     */
    /// #if_succeeds {:msg "Investor not set correctly"} investor == _investor;
    function setInvestor(address _investor) external onlyOwner {
        require(_investor != address(0), "Invalid investor address");
        investor = _investor;
        emit InvestorUpdated(investor);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./IWrap.sol";
import "../adapters/BaseAdapterBsc.sol";

interface IAdapterBsc {
    function getPaths(address _inToken, address _outToken)
        external
        view
        returns (address[] memory);

    function stakingToken() external view returns (address);

    function strategy() external view returns (address);

    function name() external view returns (string memory);

    function rewardToken() external view returns (address);

    function rewardToken1() external view returns (address);

    function router() external view returns (address);

    function swapRouter() external view returns (address);

    function deposit(uint256 _tokenId, address _account)
        external
        payable
        returns (uint256 amountOut);

    function withdraw(uint256 _tokenId, address _account)
        external
        payable
        returns (uint256 amountOut);

    function claim(uint256 _tokenId, address _account)
        external
        payable
        returns (uint256 amountOut);

    function pendingReward(uint256 _tokenId, address _account)
        external
        view
        returns (uint256 amountOut, uint256 withdrawable);

    function adapterInfos(uint256 _tokenId)
        external
        view
        returns (BaseAdapterBsc.AdapterInfo memory);

    function userAdapterInfos(address _account, uint256 _tokenId)
        external
        view
        returns (BaseAdapterBsc.UserAdapterInfo memory);

    function mAdapter()
        external
        view
        returns (BaseAdapterBsc.AdapterInfo memory);

    function getfTokenSupply(uint256 _tokenId)
        external
        view
        returns (uint256 amount);

    function getfTokenAmount(uint256 _tokenId, address _account)
        external
        view
        returns (uint256 amount);

    function getfBNBAmount(uint256 _tokenId, address _account)
        external
        view
        returns (uint256 amount);

    function removeFunds(uint256 _tokenId)
        external
        payable
        returns (uint256 amount);

    function updateFunds(uint256 _tokenId)
        external
        payable
        returns (uint256 amount);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IWrap {
    function deposit(uint256 amount) external;

    function withdraw(uint256 share) external;

    function deposit() external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IYBNFT.sol";
import "../interfaces/IFundToken.sol";
import "../interfaces/IHedgepieInvestorBsc.sol";

abstract contract BaseAdapterBsc is Ownable {
    struct UserAdapterInfo {
        uint256 amount; // Current staking token amount
        uint256 invested; // Current staked ether amount
        uint256 userShares; // First reward token share
        uint256 userShares1; // Second reward token share
        uint256 rewardDebt; // Reward Debt for reward token1
        uint256 rewardDebt1; // Reward Debt for reward token2
    }

    struct AdapterInfo {
        uint256 accTokenPerShare; // Accumulated per share for first reward token
        uint256 accTokenPerShare1; // Accumulated per share for second reward token
        uint256 totalStaked; // Total staked staking token
        uint256 invested; // Total staked bnb
    }

    uint256 public pid;

    address public stakingToken;

    address public rewardToken;

    address public rewardToken1;

    address public repayToken;

    address public strategy;

    address public router;

    address public swapRouter;

    address public investor;

    address public wbnb;

    string public name;

    AdapterInfo public mAdapter;

    // inToken => outToken => paths
    mapping(address => mapping(address => address[])) public paths;

    // user => nft id => UserAdapterInfo
    mapping(address => mapping(uint256 => UserAdapterInfo))
        public userAdapterInfos;

    // nft id => AdapterInfo
    mapping(uint256 => AdapterInfo) public adapterInfos;

    // nft id => adapterInvested
    mapping(uint256 => uint256) public adapterInvested;

    modifier onlyInvestor() {
        require(msg.sender == investor, "Not investor");
        _;
    }

    event InvestorUpdated(address investor);

    /**
     * @notice Get path
     * @param _inToken token address of inToken
     * @param _outToken token address of outToken
     */
    function getPaths(address _inToken, address _outToken)
        public
        view
        returns (address[] memory)
    {
        require(
            paths[_inToken][_outToken].length > 1,
            "Path length is not valid"
        );
        require(
            paths[_inToken][_outToken][0] == _inToken,
            "Path is not existed"
        );
        require(
            paths[_inToken][_outToken][paths[_inToken][_outToken].length - 1] ==
                _outToken,
            "Path is not existed"
        );

        return paths[_inToken][_outToken];
    }

    /**
     * @notice Set paths from inToken to outToken
     * @param _inToken token address of inToken
     * @param _outToken token address of outToken
     * @param _paths swapping paths
     */
    function setPath(
        address _inToken,
        address _outToken,
        address[] memory _paths
    ) external onlyOwner {
        require(_paths.length > 1, "Invalid paths length");
        require(_inToken == _paths[0], "Invalid inToken address");
        require(
            _outToken == _paths[_paths.length - 1],
            "Invalid inToken address"
        );

        uint8 i;
        for (i; i < _paths.length; i++) {
            if (i < paths[_inToken][_outToken].length) {
                paths[_inToken][_outToken][i] = _paths[i];
            } else {
                paths[_inToken][_outToken].push(_paths[i]);
            }
        }

        if (paths[_inToken][_outToken].length > _paths.length)
            for (
                i = 0;
                i < paths[_inToken][_outToken].length - _paths.length;
                i++
            ) paths[_inToken][_outToken].pop();
    }

    /**
     * @notice Set investor
     * @param _investor  address of investor
     */
    function setInvestor(address _investor) external onlyOwner {
        require(_investor != address(0), "Error: Investor zero address");
        investor = _investor;
        emit InvestorUpdated(investor);
    }

    /**
     * @notice deposit to strategy
     * @param _tokenId YBNFT token id
     * @param _account address of user
     */
    function deposit(uint256 _tokenId, address _account)
        external
        payable
        virtual
        returns (uint256 amountOut)
    {}

    /**
     * @notice withdraw from strategy
     * @param _tokenId YBNFT token id
     * @param _account address of user
     */
    function withdraw(uint256 _tokenId, address _account)
        external
        payable
        virtual
        returns (uint256 amountOut)
    {}

    /**
     * @notice claim reward from strategy
     * @param _tokenId YBNFT token id
     * @param _account address of user
     */
    function claim(uint256 _tokenId, address _account)
        external
        payable
        virtual
        returns (uint256 amountOut)
    {}

    /**
     * @notice Remove funds
     * @param _tokenId YBNFT token id
     */
    function removeFunds(uint256 _tokenId)
        external
        payable
        virtual
        returns (uint256 amountOut)
    {}

    /**
     * @notice Update funds
     * @param _tokenId YBNFT token id
     */
    function updateFunds(uint256 _tokenId)
        external
        payable
        virtual
        returns (uint256 amountOut)
    {}

    /**
     * @notice Get pending token reward
     * @param _tokenId YBNFT token id
     * @param _account address of user
     */
    function pendingReward(uint256 _tokenId, address _account)
        external
        view
        virtual
        returns (uint256 reward, uint256 withdrawable)
    {}

    /**
     * @notice Get user amount based on fundToken
     * @param _tokenId YBNFT token id
     * @param _account address of user
     */
    function getMUserAmount(uint256 _tokenId, address _account)
        public
        view
        returns (uint256 amount)
    {
        address fundToken = IYBNFT(IHedgepieInvestorBsc(investor).ybnft())
            .fundTokens(_tokenId);

        if (IFundToken(fundToken).totalSupply() != 0)
            amount =
                (mAdapter.totalStaked *
                    adapterInvested[_tokenId] *
                    IFundToken(fundToken).balanceOf(_account)) /
                mAdapter.invested /
                IFundToken(fundToken).totalSupply();
    }

    /**
     * @notice Get balance of fund token
     * @param _tokenId YBNFT token id
     * @param _account address of account
     */
    function getfTokenAmount(uint256 _tokenId, address _account)
        public
        view
        returns (uint256 amount)
    {
        address fundToken = IYBNFT(IHedgepieInvestorBsc(investor).ybnft())
            .fundTokens(_tokenId);

        amount = IFundToken(fundToken).balanceOf(_account);
    }

    /**
     * @notice Get balance of fund token
     * @param _tokenId YBNFT token id
     * @param _account address of account
     */
    function getfBNBAmount(uint256 _tokenId, address _account)
        public
        view
        returns (uint256 amount)
    {
        address fundToken = IYBNFT(IHedgepieInvestorBsc(investor).ybnft())
            .fundTokens(_tokenId);

        if (IFundToken(fundToken).totalSupply() != 0)
            amount =
                (adapterInvested[_tokenId] *
                    IFundToken(fundToken).balanceOf(_account)) /
                IFundToken(fundToken).totalSupply();
    }
}

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

// SPDX-License-Identifier: None
pragma solidity ^0.8.4;

interface IYBNFT {
    struct Adapter {
        uint256 allocation;
        address token;
        address addr;
    }

    function getCurrentTokenId() external view returns (uint256);

    function performanceFee(uint256 tokenId) external view returns (uint256);

    function getAdapterInfo(uint256 tokenId)
        external
        view
        returns (Adapter[] memory);

    function exists(uint256) external view returns (bool);

    function mint(
        uint256[] calldata,
        address[] calldata,
        address[] calldata,
        uint256,
        string memory
    ) external;

    function fundTokens(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./IBEP20.sol";

interface IFundToken is IBEP20 {
    /**
     * @dev Set & Disable minter
     */
    function setMinter(address, bool) external;

    /**
     * @dev Mint token function
     */
    function mint(address, uint256) external;

    /**
     * @dev Burn token function
     */
    function burn(address, uint256) external;

    /**
     * @dev called once by the factory at time of deployment
     */
    function initialize(string memory name_, string memory symbol_) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IHedgepieInvestorBsc {
    function ybnft() external view returns (address);

    function treasury() external view returns (address);

    function adapterManager() external view returns (address);

    function adapterInfo() external view returns (address);

    function updateFunds(uint256 _tokenId) external;
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

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}