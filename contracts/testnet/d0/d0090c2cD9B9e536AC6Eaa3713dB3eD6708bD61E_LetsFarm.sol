pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "../lib/SignerRecover.sol";
import "../interfaces/IBurn.sol";
import "../lib/Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "../interfaces/IMint.sol";
import "../interfaces/ILandExpand.sol";

contract LetsFarm is Upgradeable, SignerRecover, IERC721ReceiverUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    IERC20Upgradeable public hpl;
    IERC20Upgradeable public hpw;
    address public operator;

    struct UserInfo {
        uint256 hplDeposit;
        uint256 hpwDeposit;
        uint256 lastUpdatedAt;
        uint256 hplRewardClaimed;
        uint256 hpwRewardClaimed;
        uint256 lastRewardClaimedAt;
    }

    struct DepositedNFT {
        uint256[] depositedTokenIds;
        mapping(uint256 => uint256) tokenIdToIndex; //index + 1
    }

    mapping(address => UserInfo) public userInfo;
    //nft => user => DepositedNFT
    mapping(address => mapping(address => DepositedNFT)) nftUserInfo;
    //events
    event TokenDeposit(address depositor, uint256 hplAmount, uint256 hpwAmount);
    event TokenWithdraw(
        address withdrawer,
        uint256 hplAmount,
        uint256 hpwAmount
    );
    event NFTDeposit(address nft, address depositor, bytes tokenIds);
    event NFTWithdraw(address nft, address withdrawer, bytes tokenIds);

    event RewardsClaimed(address claimer, uint256 hplAmount, uint256 hpwAmount);
    event MasterRewardsClaimed(
        address claimer,
        uint256 hplAmount,
        uint256 hpwAmount
    );

    struct UserInfoTokenWithdraw {
        uint256 hplWithdraw;
        uint256 hpwWithdraw;
    }
    mapping(address => UserInfoTokenWithdraw) public userInfoTokenWithdraw;

    uint256 public minTimeBetweenClaims;
    uint256 public contractStartAt;

    struct UserInfoTokenSpend {
        uint256 totalRecordedHPLSpent;
        uint256 totalRecordedHPWSpent;
    }

    mapping(address => UserInfoTokenSpend) public userInfoTokenSpend;
    mapping(address => mapping(uint256 => uint256)) public nftDepositedTime;

    struct ScholarRewards {
        address masterWallet;
        uint256 totalHPLReceived;
        uint256 totalHPWReceived;
    }
    mapping(address => ScholarRewards) public scholarRewards;

    mapping(address => uint256) public wildLandsCount;
    uint256 public totalWildLands;
    ILandExpand public landExpand;

    uint256 public maxWithdrawPerLand;
    uint256 public maxWithdrawPerWildLand;

    function initialize(
        IERC20Upgradeable _hpl,
        IERC20Upgradeable _hpw,
        address _operator
    ) external initializer {
        initOwner();

        minTimeBetweenClaims = 10 days;
        contractStartAt = block.timestamp;

        hpl = _hpl;
        hpw = _hpw;
        operator = _operator;

        maxWithdrawPerLand = 3000 ether;
        maxWithdrawPerWildLand = 800 ether;
    }

    function setMaxWithdrawlPerLand(uint256 _normalLand, uint256 _wildLand)
        external
        onlyOwner
    {
        maxWithdrawPerLand = _normalLand;
        maxWithdrawPerWildLand = _wildLand;
    }

    function setLandExpand(address _landExpand) external onlyOwner {
        landExpand = ILandExpand(_landExpand);
    }

    function setMinTimeBetweenClaims(uint256 _minTimeBetweenClaims)
        external
        onlyOwner
    {
        minTimeBetweenClaims = _minTimeBetweenClaims;
    }

    function setContractStart() external onlyOwner {
        contractStartAt = block.timestamp;
    }

    function setContractStartWithTime(uint256 _time) external onlyOwner {
        contractStartAt = _time;
    }

    function setOperator(address _op) external onlyOwner {
        operator = _op;
    }

    function depositTokensToPlay(uint256 _hplAmount, uint256 _hpwAmount)
        public
    {
        hpl.safeTransferFrom(msg.sender, address(this), _hplAmount);
        hpw.safeTransferFrom(msg.sender, address(this), _hpwAmount);
        if (userInfo[msg.sender].lastUpdatedAt == 0) {
            //first time deposit, set lastRewardClaimedAt to current time
            userInfo[msg.sender].lastRewardClaimedAt = block.timestamp;
        }
        userInfo[msg.sender].hplDeposit += _hplAmount;
        userInfo[msg.sender].hpwDeposit += _hpwAmount;
        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit TokenDeposit(msg.sender, _hplAmount, _hpwAmount);
    }

    function depositNFTsToPlay(address _nft, uint256[] memory _tokenIds)
        external
    {
        DepositedNFT storage _user = nftUserInfo[_nft][msg.sender];
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            IERC721Upgradeable(_nft).transferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );
            _user.depositedTokenIds.push(_tokenIds[i]);
            _user.tokenIdToIndex[_tokenIds[i]] = _user.depositedTokenIds.length;
            nftDepositedTime[_nft][_tokenIds[i]] = block.timestamp;

            if (isWildLand(_tokenIds[i])) {
                wildLandsCount[msg.sender]++;
                totalWildLands++;
            }
        }

        if (userInfo[msg.sender].lastUpdatedAt == 0) {
            //first time deposit, set lastRewardClaimedAt to current time
            userInfo[msg.sender].lastRewardClaimedAt = block.timestamp;
        }

        userInfo[msg.sender].lastUpdatedAt = block.timestamp;

        emit NFTDeposit(_nft, msg.sender, abi.encodePacked(_tokenIds));
    }

    function withdrawNFTs(
        address _nft,
        uint256[] memory _tokenIds,
        uint256 _expiredTime,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external {
        require(block.timestamp < _expiredTime, "withdrawNFTs: !expired");
        bytes32 msgHash = keccak256(
            abi.encode(_nft, msg.sender, _tokenIds, _expiredTime)
        );
        require(
            operator == recoverSigner(r, s, v, msgHash),
            "invalid operator"
        );
        DepositedNFT storage _user = nftUserInfo[_nft][msg.sender];
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                nftDepositedTime[_nft][_tokenIds[i]] + 2 * 86400 <=
                    block.timestamp,
                "not nft unlock time"
            );
            require(_user.tokenIdToIndex[_tokenIds[i]] > 0, "invalid tokenId");
            IERC721Upgradeable(_nft).transferFrom(
                address(this),
                msg.sender,
                _tokenIds[i]
            );
            if (isWildLand(_tokenIds[i])) {
                wildLandsCount[msg.sender]--;
                totalWildLands--;
            }
            //swap
            uint256 _index = _user.tokenIdToIndex[_tokenIds[i]] - 1;
            _user.depositedTokenIds[_index] = _user.depositedTokenIds[
                _user.depositedTokenIds.length - 1
            ];
            _user.tokenIdToIndex[_user.depositedTokenIds[_index]] = _index + 1;
            _user.depositedTokenIds.pop();

            delete _user.tokenIdToIndex[_tokenIds[i]];
        }

        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit NFTWithdraw(_nft, msg.sender, abi.encodePacked(_tokenIds));
    }

    function withdrawTokens(
        uint256 _hplSpent,
        uint256 _hplWithdrawAmount,
        uint256 _hpwSpent,
        uint256 _hpwWithdrawAmount,
        uint256 _expiredTime,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external {
        require(block.timestamp < _expiredTime, "withdrawTokens: !expired");
        bytes32 msgHash = keccak256(
            abi.encode(
                msg.sender,
                _hplSpent,
                _hplWithdrawAmount,
                _hpwSpent,
                _hpwWithdrawAmount,
                _expiredTime
            )
        );
        require(
            operator == recoverSigner(r, s, v, msgHash),
            "invalid operator"
        );
        UserInfo storage _user = userInfo[msg.sender];
        UserInfoTokenWithdraw
            storage _userInfoTokenWithdraw = userInfoTokenWithdraw[msg.sender];
        require(
            _user.hplDeposit >=
                _hplSpent +
                    _hplWithdrawAmount +
                    _userInfoTokenWithdraw.hplWithdraw,
            "invalid hplSpent"
        );
        require(
            _user.hpwDeposit >=
                _hpwSpent +
                    _hpwWithdrawAmount +
                    _userInfoTokenWithdraw.hpwWithdraw,
            "invalid hpwSpent"
        );

        //return hpl
        hpl.safeTransfer(msg.sender, _hplWithdrawAmount);

        //return hpw
        hpw.safeTransfer(msg.sender, _hpwWithdrawAmount);

        //burn hplSpent and hpwSpent
        {
            require(
                _hplSpent >=
                    userInfoTokenSpend[msg.sender].totalRecordedHPLSpent,
                "!userInfoTokenSpend hpl"
            );
            require(
                _hpwSpent >=
                    userInfoTokenSpend[msg.sender].totalRecordedHPWSpent,
                "!userInfoTokenSpend hpw"
            );

            IBurn(address(hpl)).burn(
                _hplSpent - userInfoTokenSpend[msg.sender].totalRecordedHPLSpent
            );
            userInfoTokenSpend[msg.sender].totalRecordedHPLSpent = _hplSpent;
            IBurn(address(hpw)).burn(
                _hpwSpent - userInfoTokenSpend[msg.sender].totalRecordedHPWSpent
            );
            userInfoTokenSpend[msg.sender].totalRecordedHPWSpent = _hpwSpent;
        }

        emit TokenWithdraw(msg.sender, _hplWithdrawAmount, _hpwWithdrawAmount);

        _userInfoTokenWithdraw.hplWithdraw += _hplWithdrawAmount;
        _userInfoTokenWithdraw.hpwWithdraw += _hpwWithdrawAmount;

        _user.lastUpdatedAt = block.timestamp;
    }

    function claimRewards(
        uint256 _hplRewards,
        uint256 _hpwRewards,
        uint256 _expiredTime,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public {
        _claimRewardsInternal(_hplRewards, _hpwRewards, _expiredTime, r, s, v);
    }

    function _claimRewardsInternal(
        uint256 _hplRewards,
        uint256 _hpwRewards,
        uint256 _expiredTime,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal returns (uint256, uint256) {
        require(block.timestamp < _expiredTime, "claimRewards: !expired");
        bytes32 msgHash = keccak256(
            abi.encode(msg.sender, _hplRewards, _hpwRewards, _expiredTime)
        );
        require(
            operator == recoverSigner(r, s, v, msgHash),
            "invalid operator"
        );
        UserInfo storage _user = userInfo[msg.sender];
        //uint256 lastUpdatedAt = _user.lastUpdatedAt;
        uint256 _lastRewardClaimedAt = _user.lastRewardClaimedAt;
        _lastRewardClaimedAt = _lastRewardClaimedAt > 0
            ? _lastRewardClaimedAt
            : contractStartAt;
        require(
            _lastRewardClaimedAt + minTimeBetweenClaims < block.timestamp,
            "!minTimeBetweenClaims"
        );
        require(_user.hplRewardClaimed <= _hplRewards, "invalid _hplRewards");
        require(_user.hpwRewardClaimed <= _hpwRewards, "invalid _hpwRewards");

        uint256 toTransferHpl = _hplRewards - _user.hplRewardClaimed;
        uint256 toTransferHpw = _hpwRewards - _user.hpwRewardClaimed;

        uint256 maxWithdrawal = getMaxWithdrawal(msg.sender, false, false);

        if (toTransferHpw > maxWithdrawal) {
            toTransferHpw = maxWithdrawal;
            _hpwRewards = _user.hpwRewardClaimed + toTransferHpw;
        }
        _user.hplRewardClaimed = _hplRewards;
        _user.hpwRewardClaimed = _hpwRewards;
        _user.lastRewardClaimedAt = block.timestamp;

        hpl.safeTransfer(msg.sender, toTransferHpl);
        //mint hpw rewards
        IMint(address(hpw)).mint(msg.sender, toTransferHpw);

        emit RewardsClaimed(msg.sender, toTransferHpl, toTransferHpw);
        return (toTransferHpl, toTransferHpw);
    }

    function claimRewardsAndDeposit(
        uint256 _hplRewards,
        uint256 _hpwRewards,
        uint256 _expiredTime,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external {
        (
            uint256 _claimedHPLAmount,
            uint256 _claimedHPWAmount
        ) = _claimRewardsInternal(
                _hplRewards,
                _hpwRewards,
                _expiredTime,
                r,
                s,
                v
            );
        //deposit again
        depositTokensToPlay(_claimedHPLAmount, _claimedHPWAmount);
    }

    function masterDistributeRewards(
        uint256 _hplRewards, //total
        uint256 _hpwRewards, //total
        uint256 _expiredTime,
        address _masterAddress,
        address[] memory _scholarAddresses,
        uint256[] memory _scholarHPLAmounts, //total
        uint256[] memory _scholarHPWAmounts, //total
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external {
        require(
            block.timestamp < _expiredTime,
            "masterDistributeRewards: !expired"
        );
        bytes32 msgHash = keccak256(
            abi.encode(
                _masterAddress,
                _hplRewards,
                _hpwRewards,
                _scholarAddresses,
                _scholarHPLAmounts,
                _scholarHPWAmounts,
                _expiredTime
            )
        );
        require(
            operator == recoverSigner(r, s, v, msgHash),
            "invalid operator"
        );

        _masterDistributeRewardsInternal(
            _hplRewards,
            _hpwRewards,
            _masterAddress,
            _scholarAddresses,
            _scholarHPLAmounts,
            _scholarHPWAmounts
        );
    }

    function _masterDistributeRewardsInternal(
        uint256 _hplRewards, //total
        uint256 _hpwRewards, //total
        address _masterAddress,
        address[] memory _scholarAddresses,
        uint256[] memory _scholarHPLAmounts,
        uint256[] memory _scholarHPWAmounts
    ) internal {
        require(
            _scholarAddresses.length == _scholarHPLAmounts.length &&
                _scholarHPLAmounts.length == _scholarHPWAmounts.length,
            "!invalid input array lengths"
        );
        //compute total rewards to distribute
        UserInfo storage _user = userInfo[_masterAddress];
        //uint256 lastUpdatedAt = _user.lastUpdatedAt;
        uint256 _lastRewardClaimedAt = _user.lastRewardClaimedAt;
        _lastRewardClaimedAt = _lastRewardClaimedAt > 0
            ? _lastRewardClaimedAt
            : contractStartAt;
        require(
            _lastRewardClaimedAt + minTimeBetweenClaims < block.timestamp,
            "!minTimeBetweenClaims"
        );
        require(_user.hplRewardClaimed <= _hplRewards, "invalid _hplRewards");
        require(_user.hpwRewardClaimed <= _hpwRewards, "invalid _hpwRewards");
        uint256[2] memory maxWithdrawableNow;
        uint256 toTransferHpl = _hplRewards - _user.hplRewardClaimed;
        uint256 toTransferHpw = _hpwRewards - _user.hpwRewardClaimed;
        maxWithdrawableNow[0] = toTransferHpl;
        maxWithdrawableNow[1] = toTransferHpw;

        uint256 maxWithdrawal = getMaxWithdrawal(_masterAddress, false, true);

        if (toTransferHpw > maxWithdrawal) {
            toTransferHpw = maxWithdrawal;
            _hpwRewards = _user.hpwRewardClaimed + toTransferHpw;
        }

        if (toTransferHpl > maxWithdrawal) {
            toTransferHpl = maxWithdrawal;
            _hplRewards = _user.hplRewardClaimed + toTransferHpl;
        }
        _user.hplRewardClaimed = _hplRewards;
        _user.hpwRewardClaimed = _hpwRewards;
        _user.lastRewardClaimedAt = block.timestamp;

        //distribute hpl
        if (toTransferHpl > 0) {
            _distributeHPLToScholars(
                toTransferHpl,
                maxWithdrawableNow[0],
                _masterAddress,
                _scholarAddresses,
                _scholarHPLAmounts
            );
        }

        //distribute hpw
        if (toTransferHpw > 0) {
            _distributeHPWToScholars(
                toTransferHpw,
                maxWithdrawableNow[1],
                _masterAddress,
                _scholarAddresses,
                _scholarHPWAmounts
            );
        }
        emit MasterRewardsClaimed(msg.sender, toTransferHpl, toTransferHpw);
    }

    function _distributeHPLToScholars(
        uint256 _toTransferHpl, //total
        uint256 _maxWithdraw,
        address _masterAddress,
        address[] memory _scholarAddresses,
        uint256[] memory _scholarHPLAmounts
    ) internal {
        uint256 _totalTransferredHPL = 0;
        for (uint256 i = 0; i < _scholarAddresses.length; i++) {
            require(
                scholarRewards[_scholarAddresses[i]].masterWallet ==
                    address(0) ||
                    scholarRewards[_scholarAddresses[i]].masterWallet ==
                    _masterAddress,
                "same scholar, different master"
            );
            scholarRewards[_scholarAddresses[i]].masterWallet = _masterAddress;

            uint256 _scholarClaimable = _scholarHPLAmounts[i].sub(
                scholarRewards[_scholarAddresses[i]].totalHPLReceived
            );
            _scholarClaimable =
                (_scholarClaimable * _toTransferHpl) /
                _maxWithdraw;
            scholarRewards[_scholarAddresses[i]]
                .totalHPLReceived += _scholarClaimable;
            _totalTransferredHPL += _scholarClaimable;
            hpl.safeTransfer(_scholarAddresses[i], _scholarClaimable);
        }
        require(
            _totalTransferredHPL <= _toTransferHpl,
            "exceed total allowed hpl rewards transfer"
        );
        hpl.safeTransfer(_masterAddress, _toTransferHpl - _totalTransferredHPL);
    }

    function _distributeHPWToScholars(
        uint256 _toTransferHpw, //total
        uint256 _maxWithdraw,
        address _masterAddress,
        address[] memory _scholarAddresses,
        uint256[] memory _scholarHPWAmounts
    ) internal {
        uint256 _totalTransferredHPW = 0;
        for (uint256 i = 0; i < _scholarAddresses.length; i++) {
            require(
                scholarRewards[_scholarAddresses[i]].masterWallet ==
                    address(0) ||
                    scholarRewards[_scholarAddresses[i]].masterWallet ==
                    _masterAddress,
                "same scholar, different master"
            );
            scholarRewards[_scholarAddresses[i]].masterWallet = _masterAddress;

            uint256 _scholarClaimable = _scholarHPWAmounts[i].sub(
                scholarRewards[_scholarAddresses[i]].totalHPWReceived
            );
            _scholarClaimable =
                (_scholarClaimable * _toTransferHpw) /
                _maxWithdraw;
            scholarRewards[_scholarAddresses[i]]
                .totalHPWReceived += _scholarClaimable;
            _totalTransferredHPW += _scholarClaimable;
            IMint(address(hpw)).mint(_scholarAddresses[i], _scholarClaimable);
        }
        require(
            _totalTransferredHPW <= _toTransferHpw,
            "exceed total allowed hpl rewards transfer"
        );
        IMint(address(hpw)).mint(
            _masterAddress,
            _toTransferHpw - _totalTransferredHPW
        );
    }

    function getUserInfo(address _user)
        external
        view
        returns (
            uint256 hplDeposit,
            uint256 hpwDeposit,
            uint256 lastUpdatedAt,
            uint256 hplRewardClaimed,
            uint256 hpwRewardClaimed
        )
    {
        UserInfo storage _userInfo = userInfo[_user];
        return (
            _userInfo.hplDeposit,
            _userInfo.hpwDeposit,
            _userInfo.lastUpdatedAt,
            _userInfo.hplRewardClaimed,
            _userInfo.hpwRewardClaimed
        );
    }

    function getUserInfo2(address _user)
        external
        view
        returns (
            uint256 hplDeposit,
            uint256 hpwDeposit,
            uint256 lastUpdatedAt,
            uint256 hplRewardClaimed,
            uint256 hpwRewardClaimed,
            uint256 lastRewardClaimedAt
        )
    {
        UserInfo storage _userInfo = userInfo[_user];
        return (
            _userInfo.hplDeposit,
            _userInfo.hpwDeposit,
            _userInfo.lastUpdatedAt,
            _userInfo.hplRewardClaimed,
            _userInfo.hpwRewardClaimed,
            _userInfo.lastRewardClaimedAt
        );
    }

    function getDepositedNFTs(address _nft, address _user)
        external
        view
        returns (uint256[] memory depositedLands)
    {
        return nftUserInfo[_nft][_user].depositedTokenIds;
    }

    function getDepositedNFTs2(address _nft, address _user)
        external
        view
        returns (uint256[] memory depositedLands)
    {
        return nftUserInfo[_nft][_user].depositedTokenIds;
    }

    function onERC721Received(
        address _operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        //do nothing
        return bytes4("");
    }

    function getLandDepositedCount(address _addr, address _nft)
        public
        view
        returns (uint256 total, uint256 wildLandCount)
    {
        return (
            nftUserInfo[_nft][_addr].depositedTokenIds.length,
            wildLandsCount[_addr]
        );
    }

    function getChainId() public view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function getScholarRewardsClaimed(address[] memory _scholars)
        external
        view
        returns (uint256[] memory _hplClaimeds, uint256[] memory _hpwClaimeds)
    {
        _hplClaimeds = new uint256[](_scholars.length);
        _hpwClaimeds = new uint256[](_scholars.length);

        for (uint256 i = 0; i < _scholars.length; i++) {
            _hplClaimeds[i] = scholarRewards[_scholars[i]].totalHPLReceived;
            _hpwClaimeds[i] = scholarRewards[_scholars[i]].totalHPWReceived;
        }
    }

    function getLandContract() public view returns (address) {
        address _land = 0x9c271b95A2Aa7Ab600b9B2E178CbBec2A6dc1bAb;
        {
            uint256 _chainId = getChainId();
            if (_chainId == 97) {
                _land = 0x03524a0561f20Cd4cE73EAE1057cFa29B29C40D1;
            } else if (_chainId == 56) {
                //do nothing
            } else {
                revert("unsupported chain");
            }
        }
        return _land;
    }

    function getMaxWithdrawal(
        address _user,
        bool _tightCheck,
        bool _forGuild
    ) public view returns (uint256) {
        (
            uint256 depositedLandCount,
            uint256 wildLandCount
        ) = getLandDepositedCount(_user, getLandContract());
        // if (_tightCheck) {
        //     depositedLandCount = getLandCountForRewardsClaim(_user);
        // }
        uint256 normalLand = depositedLandCount.sub(wildLandCount);
        uint256 _maxPerLand = maxWithdrawPerLand != 0
            ? maxWithdrawPerLand
            : (3000 ether);
        uint256 _maxPerWildLand = maxWithdrawPerWildLand != 0
            ? maxWithdrawPerWildLand
            : (800 ether);
        uint256 maxWithdrawal = (normalLand *
            _maxPerLand +
            wildLandCount *
            _maxPerWildLand);
        if (!_forGuild) {
            if (maxWithdrawal > 10000 ether) {
                maxWithdrawal = 10000 ether;
            }
        }

        return maxWithdrawal;
    }

    function getLandCountForRewardsClaim(address _user)
        public
        view
        returns (uint256)
    {
        address _land = getLandContract();
        uint256[] storage _depositedTokenIds = nftUserInfo[_land][_user]
            .depositedTokenIds;
        uint256 ret = 0;
        for (uint256 i = 0; i < _depositedTokenIds.length; i++) {
            if (
                nftDepositedTime[_land][_depositedTokenIds[i]] +
                    minTimeBetweenClaims <
                block.timestamp
            ) {
                ret++;
            }
        }

        return ret;
    }

    function isWildLand(uint256 _tokenId) public view returns (bool) {
        if (address(landExpand) != address(0)) {
            if (landExpand.wildLandTokens(_tokenId)) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

pragma solidity ^0.8.0;

contract SignerRecover {
    function recoverSigner(bytes32 r, bytes32 s, uint8 v, bytes32 signedData) internal view returns (address) {
        address signer = ecrecover(keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", signedData)
            ), v, r, s);

        return signer;
    }
}

pragma solidity ^0.8.0;

interface IBurn {
    function burn(uint256 amount) external;
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Upgradeable is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function initOwner() internal {
        __Ownable_init();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.8.0;

interface IMint {
    function mint(address _to, uint256 _amount) external;
}

pragma solidity ^0.8.0;

interface ILandExpand {
    function wildLandTokens(uint256 _tokenId) external view returns (bool);

    function usedLands(uint256 _tokenId) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _upgradeTo(newImplementation);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}