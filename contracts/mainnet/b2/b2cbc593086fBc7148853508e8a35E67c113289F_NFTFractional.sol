// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Upgradable.sol";
import "../nft-token/ERC20Token.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../nft-token/INFTToken.sol";
import "./ISignatureUtils.sol";

contract NFTFractional is Upgradable {
    using SafeERC20 for IERC20;

    /**
     * @dev Contract owner set admin for execute administrator functions
     * @param _address wallet address of admin
     * @param _value 1: admin, 2: user, 3:controller
    */
    function setAdmin(address _address, uint256 _value) external onlyController {
        require(_address != address(0), "NFTFractional: Admin is not the zero address");
        adminList[_address] = _value;
        emit AdminSet(_address, _value);
    }

    /**
     * @dev check wallet if wallet address is admin or not
     * @param _address wallet address of the user
     * @return result rule --> 1: admin, 2: user, 3: controller 
    */
    function isAdmin(address _address) external view returns (uint256) {
        return adminList[_address];
    }

    /**
    * @dev Transfers controller of the contract to a new account (`newController`).
    * @param _newController Adress to set new controller
    * Can only be called by the current controller.
    */
    function transferController(address _newController) external {
        // Check if controller has been initialized in proxy contract
        // Caution If set controller != proxyOwnerAddress then all functions require controller permission cannot be called from proxy contract
        if (controller != address(0)) {
            require(msg.sender == controller, "NFTFractional: Only controller");
        }
        require(_newController != address(0), "NFTFractional: New controller is the zero address");
        _transferController(_newController);
    }

    /**
    * @dev Transfers controller of the contract to a new account (`newController`).
    * Internal function without access restriction.
    * @param _newController address for new controller
    */
    function _transferController(address _newController) internal {
        controller = _newController;
    }

    /**
    * @dev set collection of nft token
    */
    function initial(
        address _signatureUtils,
        address _nftToken) 
            external onlyController {
        nftToken = _nftToken;
        signatureUtils = _signatureUtils;
    }

    /**
     * @dev mint NFT
     * @param _tokenId token id of NFT
    */
    function mintNFT(uint256 _tokenId) external onlyAdmins {
        INFTToken(nftToken).mintNFT(address(this), _tokenId);
        emit MintNFT(nftToken, address(this), _tokenId);
    }

    /**
    * @dev fractionalize nft to bep20 token
    * @param _token token of NFT
    * @param _totalSupply total supply of bep20 token
    * @param _tokenId token id of NFT
    * @param _name name of bep20 token
    * @param _symbol symbol of bep20 token
    */
    function fractionalizeNFT(
        address _token,
        uint256 _totalSupply,
        uint256 _tokenId,
        string memory _name,
        string memory _symbol) external onlyAdmins notEmpty(_name) notEmpty(_symbol) {
            require(_totalSupply > 0, "NFTFractional: Total supply not greater than zero");
            require(fnftInfos[_tokenId].tokenNFT == address(0), "NFTFractional: NFT fractionalized");
            ERC20Token tokenERC20 = new ERC20Token(_name, _symbol);
            ERC20Token(tokenERC20).mintERC20(address(this), _totalSupply);
            FNFTInfo memory fNFTInfo = FNFTInfo(_tokenId,_totalSupply, _totalSupply, address(this), _token, address(tokenERC20));
            fnftInfos[_tokenId] = fNFTInfo;
            emit FractionalizeNFT(_token, address(tokenERC20), address(this), _totalSupply, _tokenId ,_symbol, _name);
    }

    /**
    * @dev create functional F-NFT Pool to user buy token F-NFT by USDT token or other tokens
    * @param _addrs acceptToken(0), receiveAddress(1)
    * @param _datas poolId(0), fnftId(1), poolBalance(2), active(3), poolType(4)
    * @param _configs registrationStartTime(0), registrationEndTime(1), purchaseStartTime(2), purchaseEndTime(3)
    */
    function createFNFTPool(address[] memory _addrs, uint256[] memory _datas, uint256[] memory _configs) external onlyAdmins {
        require(_addrs[0] != address(0) || _addrs[1] != address(0), "NFTFractional: Address is not the zero address");
        // pool balance > 0
        require(_datas[2] > 0, "NFTFractional: Pool balance must greater then zero");
        
        // require(block.timestamp <= _configs[0], "NFTFractional: Current Time is less then Registration Start Time");
        require(_configs[0] <= _configs[1], "NFTFractional: Registration Start Time is less then Registration End Time");
        require(_configs[1] <= _configs[2], "NFTFractional: Registration End Time is less then Purchasing Start Time");
        require(_configs[2] <= _configs[3], "NFTFractional: Purchasing Start Time is less then Purchasing End Time");

        FNFTInfo storage fnft = fnftInfos[_datas[1]];
        // check fnt exists
        require(fnft.tokenNFT != address(0), "NFTFractional: FNFT is not exist");
        require(fnftPools[_datas[0]].acceptToken == address(0), "NFTFractional: the FNFT exists");
        // pool balance < available supply fnft
        require(_datas[2] <=  fnft.availableSupply, "NFTFractional: Pool balance must less then available supply");
        fnft.availableSupply -= _datas[2];
        FNFTPool memory pool;
        if(_datas[4] == 2) {
            pool = FNFTPool(_addrs[0], _addrs[1], _datas[0], _datas[1], _datas[2], _datas[2],_datas[3], _datas[4], _configs);
        } else {
            pool = FNFTPool(_addrs[0], _addrs[1], _datas[0], _datas[1], _datas[2], _datas[2],_datas[3], 1, _configs);
        }
        fnftPools[_datas[0]] = pool;
        emit CreateFNFTPool(_addrs[0], _addrs[1], _datas[0], _datas[1], _datas[2], _datas[3]);
    }

    function configsOfFNFTPool(uint256 poolId) external view returns (uint256[] memory){
        FNFTPool memory pool = fnftPools[poolId];
        return pool.configs;
    }

    /**
    * @dev create tier pool for user stake token to level up tier
    * @param _addr staking token address
    * @param _datas poolID(0), lockDuration(1), withdrawDelayDuration(2), active(3)
    */
    function createTieringPool(address _addr, uint256[] memory _datas) external onlyAdmins {
        require(_addr != address(0), "NFTFractional: Address is not the zero address");
        TierPool storage pool = tierPools[_datas[0]];
        if (pool.stakingToken == address(0)) {
            tierPools[_datas[0]] = TierPool(_addr, 0, 0, _datas[1], _datas[2], _datas[3]);
        } else {
            pool.stakingToken = _addr;
            pool.lockDuration = _datas[1];
            pool.withdrawDelayDuration = _datas[2];
            pool.active = _datas[3];
        }
        emit CreateTierPool(_addr, _datas[0], _datas[1], _datas[2]);
    }

    /**
    * @dev create reward pool for user swap f-nft token to usdt token
    * @param _addr reward token address
    * @param _datas poolID(0), fnftPoolId(1), totalRewardAmount(2), poolOpenTime(3), active(4)
    */
    function createRewardPool(address _addr, uint256[] memory _datas) external onlyAdmins {
        require(_addr != address(0), "NFTFractional: Address is not the zero address");  
        FNFTPool storage fnftPool = fnftPools[_datas[1]];
        // check f-nft pool exist
        require(fnftPool.acceptToken != address(0), "NFTFractional: FNFT Pool does not exist");
        // totalRewardAmount > 0
        require(_datas[2] > 0, "NFTFractional: Total Reward Amount must greater than zero");
        // poolOpenTime >= purchase end time
        require(_datas[3] >= fnftPool.configs[3], "NFTFractional: Pool Open Time must greater than purchase end time");
        RewardPool storage pool = rewardPools[_datas[0]];
        if (pool.rewardToken == address(0)) {
            rewardPools[_datas[0]] = RewardPool(_addr, _datas[1], _datas[2], _datas[3], _datas[4]);
        } else {
            pool.rewardToken = _addr;
            pool.totalRewardAmount = _datas[2];
            pool.active = _datas[4];
        }
        emit CreateRewardPool(_addr, _datas[0], _datas[1], _datas[2], _datas[3], _datas[4]);
    }

    /**
     * @dev Withdraw fund admin has sent to the pool
     * @param _tokenAddress: the token contract owner want to withdraw fund
     * @param _account: the account which is used to receive fund
     * @param _poolId: poolId of FNFT Pool
    */
    function withdrawFund(address _tokenAddress, address _account, uint256 _poolId) external onlyAdmins {
        FNFTPool storage pool = fnftPools[_poolId];
        FNFTInfo storage fnftInfos = fnftInfos[pool.fnftId];
        require(tierPools[_poolId].stakingToken == address(0), "NFTFractional: Tier pool is not allowed to withdraw fund");
        require(pool.acceptToken != address(0), "NFTFractional: Pool does not exist");
        require(pool.configs[3] < block.timestamp, "NFTFractional: Pool does not finish");
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(_account, balance);
        pool.availableBalance = 0 ;
        fnftInfos.availableSupply = 0;
        emit WithdrawFun(_poolId, balance, _tokenAddress, _account);
    }

    function withdrawFundToken(address _tokenAddress, address _account) external onlyController {
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(_account, balance);
    }

    function setAddressSigner(address _signer) external onlyAdmins {
        signer = _signer;
    }

    /**
    * @dev function to user can purchase f-nft
    * @param _datas poolId(0), amount(1), alloction(2), purchaseFNFT(3), nonce(4)
    * @param _purchaseId purchase id of transaction
    * @param _signature signature of user
    * @param _addressUser address of user
    */
    function purchaseFNFT(uint256[] memory _datas, string memory _purchaseId,bytes memory _signature, address _addressUser) external {
        require(
            ISignatureUtils(signatureUtils).verify(
                _datas[0],
                _datas[1],
                _datas[4],
                1,
                msg.sender,
                signer,
                _signature
            ),
            "NFTFractional: Invalid Address Signer"
        );
        require(nonceSignatures[_signature] == 0, "NFTFractional: The signature has been used");
        nonceSignatures[_signature] = _datas[4];
        FNFTPool storage pool = fnftPools[_datas[0]];
        FNFTInfo storage fnftInfo = fnftInfos[pool.fnftId];
        UserInfo storage userInfo = userInfos[_datas[0]][_addressUser];
        // check FNFTPool exists
        if(pool.acceptToken == address(0)) {
            revert();
        }
        // check FNFTInfo exists
        if (fnftInfo.totalSupply == 0) {
            revert();
        }
        // current time >= purchase start time
        require(block.timestamp >= pool.configs[2], "NFTFractional: Current time must greater than purchase start time");
        // current time <= purchase end time
        require(pool.configs[3] >= block.timestamp, "NFTFractional: Purchase end time must greater than current time");
     
        if (userInfo.alloction == 0) {
            userInfo.alloction = _datas[2];
        }
        require(_datas[1] + userInfo.purchased <= userInfo.alloction, "NFTFractional: Limit allocation");
        require(_datas[3] <= pool.availableBalance, "NFTFractional: Amount must less then available balance pool");

        IERC20(pool.acceptToken).transferFrom(_addressUser, pool.receiveAddress, _datas[1]);
        IERC20(fnftInfo.tokenFNFT).transfer(_addressUser, _datas[3]);

        pool.availableBalance -= _datas[3];
        userInfo.purchased += _datas[1];
        emit PurchaseFNFT(_datas[0], userInfo.purchased, userInfo.alloction - userInfo.purchased, _datas[3], _addressUser, _purchaseId);
    }

    /**
    * @dev function to user stake to tier pool
    * @param _datas tierPoolId(0), amount(1)
    */
    function stakeTierPool(uint256[] memory _datas) external {
        TierPool storage pool = tierPools[_datas[0]];
        // check pool exist
        require(pool.stakingToken != address(0), "NFTFractional: Pool is not exist");
        // check amount > 0
        require(_datas[1] > 0, "NFTFractional: Amount is greater than zero");
        // pool must active
        require(pool.active == 1, "NFTFractional: Tiring Pool must active");
        // check balanceOf >= amount
        require(IERC20(pool.stakingToken).balanceOf(msg.sender) >= _datas[1], "NFTFractional: Not enought balance");
        IERC20(pool.stakingToken).transferFrom(msg.sender, address(this), _datas[1]);
        pool.stakedBalance += _datas[1];
        UserInfo storage userInfo = userInfos[_datas[0]][msg.sender];
        userInfo.stakeLastTime = block.timestamp;
        userInfo.stakeBalance += _datas[1];
        stakingBalances[pool.stakingToken] += _datas[1];
        emit StakeTierPool(msg.sender, _datas[0], _datas[1]);
    }

    /**
    * @dev function to user stake to tier pool
    * @param _datas tierPoolId(0), amount(1)
    */
    function unStakeTierPool(uint256[] memory _datas) external {
        TierPool storage pool = tierPools[_datas[0]];
        // check pool exists
        require(pool.stakingToken != address(0), "NFTFractional: Pool is not exist");
        // check amount > 0
        require(_datas[1] > 0, "NFTFractional: Amount is greater than zero");
        // pool must active
        require(pool.active == 1, "NFTFractional: Tiring Pool must active");
        // check balanceOf >= amount
        require(IERC20(pool.stakingToken).balanceOf(address(this)) >= _datas[1], "NFTFractional: Not enought balance");
        UserInfo storage userInfo = userInfos[_datas[0]][msg.sender];
        require(userInfo.stakeLastTime + pool.lockDuration * ONE_DAY_IN_SECONDS < block.timestamp, "NFTFractional: User is in lock duration");
        if (pool.withdrawDelayDuration > 0) {
            userInfo.pendingWithdraw += _datas[1];
        } else {
            stakingBalances[pool.stakingToken] -= _datas[1];
            IERC20(pool.stakingToken).transfer(msg.sender, _datas[1]);
        }
        userInfo.unStakeLastTime = block.timestamp;
        pool.stakedBalance -= _datas[1];
        userInfo.stakeBalance -= _datas[1];
        emit UnStakeTierPool(msg.sender, _datas[0], _datas[1]);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    /**
    * @dev function withdraw delay token for user
    * @param poolId id of tier pool
    */
    function withdrawDelayToken(uint256 poolId) external {
        TierPool storage tierPool = tierPools[poolId];
        require(tierPool.stakingToken != address(0), "Tier Pool is not exist");
        // pool must active
        require(tierPool.active == 1, "NFTFractional: Tiring Pool must active");
        // require(tierPool.withdrawDelayDuration > 0, "Tier Pool must have withdrawDelayDuration > 0");
        UserInfo storage userInfo = userInfos[poolId][msg.sender];
        require(block.timestamp - userInfo.unStakeLastTime >= tierPool.withdrawDelayDuration * ONE_DAY_IN_SECONDS, "Pool doesnt finish withraw delay duration");
        stakingBalances[tierPool.stakingToken] -= userInfo.pendingWithdraw;
        IERC20(tierPool.stakingToken).transfer(msg.sender, userInfo.pendingWithdraw);
        userInfo.pendingWithdraw = 0;
    }

    /**
    * @dev function to user can claim reward
    * @param _datas poolId(0), amountFNFT(1), alloction(2), rewardUSDT(3), nonce(4)
    * @param _claimId claim id of transaction
    * @param _signature signature of user
    * @param _addressUser address of user
    */
    function claimReward(uint256[] memory _datas, string memory _claimId,bytes memory _signature, address _addressUser) external {
        require(
            ISignatureUtils(signatureUtils).verify(
                _datas[0],
                _datas[1],
                _datas[4],
                2,
                msg.sender,
                signer,
                _signature
            ),
            "NFTFractional: Invalid Address Signer"
        );
        require(nonceSignatures[_signature] == 0, "NFTFractional: The signature has been used");
        nonceSignatures[_signature] = _datas[4];
        RewardPool storage rewardPool = rewardPools[_datas[0]];
        FNFTPool storage fnftPool = fnftPools[rewardPool.fnftPoolId];
        FNFTInfo storage fnftInfo = fnftInfos[fnftPool.fnftId];
        uint256 balanceSender = IERC20(fnftInfo.tokenFNFT).balanceOf(_addressUser);
        require(rewardPool.rewardToken != address(0) && fnftPool.acceptToken != address(0), "NFTFractional: The reward pool is not exist");
        require(rewardPool.poolOpenTime <= block.timestamp, "NFTFractional: The pool does not open");
        require(balanceSender >= _datas[1], "NFTFractional: insuffcient balance");
        uint256 amountTransfer = rewardPool.totalRewardAmount >= _datas[3] ? _datas[3] : rewardPool.totalRewardAmount;
        IERC20(fnftInfo.tokenFNFT).transferFrom(_addressUser, address(this), _datas[1]);
        IERC20(rewardPool.rewardToken).transfer(_addressUser, amountTransfer);
        ERC20Token(fnftInfo.tokenFNFT).burnFrom(address(this), _datas[1]);
        rewardPool.totalRewardAmount -= amountTransfer;
        emit ClaimReward(_datas[0], _datas[1], balanceSender - _datas[1] , amountTransfer, _addressUser, _claimId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract Upgradable {
    uint256 constant ONE_DAY_IN_SECONDS = 86400;
    address public nftToken; // contract address of NFTToken
    address public controller;
    address public signer;
    address public signatureUtils;
    mapping(address => uint256) public adminList; // 1: admin, 3: controller
    mapping(uint256 => FNFTInfo) public fnftInfos;
    mapping(uint256 => FNFTPool) public fnftPools;
    mapping(uint256 => TierPool) public tierPools;
    mapping(uint256 => RewardPool) public rewardPools;
    mapping(uint256 => mapping(address => UserInfo)) public userInfos;
    mapping(address => uint256) public stakingBalances;
    mapping(bytes => uint256) public nonceSignatures;
    
    /// --------------------------------
    /// -------- MODIFIERS --------
    /// --------------------------------

    modifier onlyController() {
        require(msg.sender == controller || adminList[msg.sender] == 3, "NFTFractional: Only controller");
        _;
    }

    modifier notEmpty(string memory _value) {
        require(bytes(_value).length > 0, "NFTFractional: Not Empty");
        _;
    }

    modifier onlyAdmins() {
        require(msg.sender == controller || adminList[msg.sender] == 1 || adminList[msg.sender] == 3, "NFTFractional: Only controller and admins");
        _;
    }

    modifier checkTierIndex(uint256[] memory tiers, uint256 _index) {
        require(tiers.length > _index, "NFTFractional: Invalid tier index");
        _;
    }

    modifier isFractionalizedNFT(uint256 id) {
        require(fnftInfos[id].totalSupply == 0, "NFT fractionalized");
        _;
    }

    /// --------------------------------
    /// -------- EVENTS --------
    /// --------------------------------

    event AdminSet(
        address indexed admin,
        uint256 isSet
    );

    event MintNFT(
        address indexed _nftToken,
        address indexed _receiver,
        uint256 _tokenId
    );

    event ControllerTransferred(
        address indexed previousController, 
        address indexed newController
    );

    event FractionalizeNFT(
        address indexed _tokenNFT,
        address indexed _tokenFNFT,
        address indexed _curator,
        uint256 _totalSupply,
        uint256 _tokenId,
        string _symbol,
        string _name
    );

    event CreateFNFTPool(
        address _acceptToken,
        address _receiveAddress,
        uint256 _poolId,
        uint256 _fnftId,
        uint256 _poolBalance,
        uint256 _active // pool activation status, 0: disable, 1: active
    );

    event CreateTierPool(
        address _stakingToken,
        uint256 _poolId,
        uint256 _lockDuration,
        uint256 _withdrawDelayDuration
    );

    event CreateRewardPool(
        address _rewardToken,
        uint256 _rewardPoolId,
        uint256 _fnftPoolId,
        uint256 _totalRewardAmount,
        uint256 _poolOpenTime,
        uint256 _active
    );

    event StakeTierPool(
        address account,
        uint256 poolId,
        uint256 amount 
    );

    event UnStakeTierPool(
        address account,
        uint256 poolId,
        uint256 amount 
    );

    event PurchaseFNFT(
        uint256 poolId,
        uint256 purchased,
        uint256 remaining,
        uint256 purchasedFNFT,
        address account,
        string purchaseId
    );

    event ClaimReward(
        uint256 poolId,
        uint256 amountFNFT,
        uint256 remaining,
        uint256 rewardUSDT,
        address account,
        string claimId
    );

    event WithdrawFun(
        uint256 poolId,
        uint256 amount,
        address token,
        address account
    );

    /// --------------------------------
    /// -------- STRUCT --------
    /// --------------------------------

    struct FNFTInfo {
        uint256 id;
        uint256 totalSupply;
        uint256 availableSupply;
        address curator;
        address tokenNFT;
        address tokenFNFT;
    }

    struct FNFTPool {
        address acceptToken;
        address receiveAddress;
        uint256 poolId;
        uint256 fnftId;
        uint256 poolBalance;
        uint256 availableBalance;
        uint256 active; // pool activation status, 0: disable, 1: active
        uint256 poolType; // 1: tiered, 2: FCFS
        uint256[] configs; // registrationStartTime(0), registrationEndTime(1), purchaseStartTime(2), purchaseEndTime(3)
    }

    struct TierPool {
        address stakingToken; // staking token of the pool
        uint256 stakedBalance; // total balance staked the pool
        uint256 totalUserStaked; // total user staked
        uint256 lockDuration;
        uint256 withdrawDelayDuration;
        uint256 active;
    }

    struct RewardPool {
        address rewardToken;
        uint256 fnftPoolId;
        uint256 totalRewardAmount;
        uint256 poolOpenTime;
        uint256 active;
    }

    struct UserInfo {
        uint256 alloction;
        uint256 purchased;
        uint256 stakeBalance;
        uint256 stakeLastTime;
        uint256 unStakeLastTime;
        uint256 pendingWithdraw;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract ERC20Token is ERC20Upgradeable {

  address private owner;
  constructor(string memory _name, string memory _symbol) initializer {
    __ERC20_init(_name, _symbol);
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(owner == msg.sender, "ERC20Token: Only controllers");
    _;
  }

  function mintERC20(address _curator, uint256 _supply) external onlyOwner {
    _mint(_curator, _supply);
  }

  function burnFrom(address account, uint256 amount) public onlyOwner {
    // _spendAllowance(_msgSender(),account, amount);
    _burn(account, amount);
  }

  function decimals() public view virtual override returns (uint8) {
    return 8;
  }
  
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";

interface INFTToken {
  function transferController(address _newController) external;
  function mintNFT (address _receiver, uint256 _tokenId) external returns(uint256);
  function burn (uint256 _tokenId) external;
  function setBaseURI(string memory _uri) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISignatureUtils {
    function getMessageHash(uint256 poolId,uint256 amount, uint256 nonce, uint256 typeSignature,address sender) external returns (bytes32);
    function getEthSignedMessageHash(bytes32 _messageHash) external returns (bytes32);
    function verify(uint256 poolId,uint256 amount, uint256 nonce,uint256 typeSignature, address sender,address signer,bytes memory signature) external returns (bool);
    function recoverSigner(bytes32 hash, bytes memory signature) external returns (address);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}