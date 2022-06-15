// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Ownable.sol";
import "AccessControl.sol";
import "IERC20.sol";
import "Strings.sol";
import {SavvyFinanceFarmLibrary as Lib} from "SavvyFinanceFarmLibrary.sol";

contract SavvyFinanceFarm is Ownable, AccessControl {
    address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

    struct ConfigDetails {
        address developmentWallet;
        uint256 minimumTokenNameLength;
        uint256 maximumTokenNameLength;
        uint256 minimumStakingApr;
        uint256 maximumStakingApr;
        uint256 defaultStakingApr;
        uint256 minimumStakeUnstakeFee;
        uint256 maximumStakeUnstakeFee;
        uint256 defaultStakeUnstakeFee;
        uint256 minimumDepositWithdrawFee;
        uint256 maximumDepositWithdrawFee;
        uint256 defaultDepositWithdrawFee;
    }
    ConfigDetails public configData;

    // token => bool
    mapping(address => bool) public isExcludedFromFees;
    // categoryNumber => categoryName
    mapping(uint256 => string) public tokenCategory;
    // token => address => bool
    mapping(address => mapping(address => bool))
        public isExcludedFromTokenAdminFees;

    address[] public tokens;
    struct TokenFeesDetails {
        uint256 devDepositFee;
        uint256 devWithdrawFee;
        uint256 devStakeFee;
        uint256 devUnstakeFee;
        uint256 adminStakeFee;
        uint256 adminUnstakeFee;
    }
    struct TokenDetails {
        // uint256 index;
        bool isActive;
        bool isVerified;
        bool hasMultiTokenRewards;
        string name;
        uint256 category;
        uint256 price;
        uint256 rewardBalance;
        uint256 stakingBalance;
        uint256 stakingApr;
        address rewardToken;
        address admin;
        TokenFeesDetails fees;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => TokenDetails) public tokensData;

    address[] public stakers;
    struct StakerDetails {
        // uint256 index;
        bool isActive;
        uint256 uniqueTokensStaked;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => StakerDetails) public stakersData;

    struct TokenStakerRewardDetails {
        uint256 id;
        address staker;
        address rewardToken;
        uint256 rewardTokenPrice;
        uint256 rewardTokenAmount;
        address stakedToken;
        uint256 stakedTokenPrice;
        uint256 stakedTokenAmount;
        uint256 stakingApr;
        uint256 stakingDurationInSeconds;
        string[2] triggeredBy;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    struct TokenStakerDetails {
        uint256 rewardBalance;
        uint256 stakingBalance;
        address stakingRewardToken;
        TokenStakerRewardDetails[] stakingRewards;
        uint256 timestampLastRewarded;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    // token => staker => TokenStakerDetails
    mapping(address => mapping(address => TokenStakerDetails))
        public tokensStakersData;

    // event Stake(address indexed staker, address indexed token, uint256 amount);
    // event Unstake(
    //     address indexed staker,
    //     address indexed token,
    //     uint256 amount
    // );
    // event IssueStakingReward(
    //     address indexed staker,
    //     address indexed token,
    //     TokenStakerRewardDetails rewardData
    // );
    // event WithdrawStakingReward(
    //     address indexed staker,
    //     address indexed reward_token,
    //     uint256 amount
    // );

    // constructor() {
    //     configData.developmentWallet = _msgSender();
    //     configData.minimumTokenNameLength = 2;
    //     configData.maximumTokenNameLength = 15;
    //     configData.minimumStakingApr = _toWei(50);
    //     configData.maximumStakingApr = _toWei(1000);
    //     configData.defaultStakingApr = _toWei(100);
    //     configData.minimumStakeUnstakeFee = 0;
    //     configData.maximumStakeUnstakeFee = _toWei(10);
    //     configData.defaultStakeUnstakeFee = _toWei(1);
    //     configData.minimumDepositWithdrawFee = 0;
    //     configData.maximumDepositWithdrawFee = _toWei(10);
    //     configData.defaultDepositWithdrawFee = _toWei(1);
    //     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    // }

    function initialize() external {
        configData.developmentWallet = _msgSender();
        configData.minimumTokenNameLength = 2;
        configData.maximumTokenNameLength = 15;
        configData.minimumStakingApr = _toWei(50);
        configData.maximumStakingApr = _toWei(1000);
        configData.defaultStakingApr = _toWei(100);
        configData.minimumStakeUnstakeFee = 0;
        configData.maximumStakeUnstakeFee = _toWei(10);
        configData.defaultStakeUnstakeFee = _toWei(1);
        configData.minimumDepositWithdrawFee = 0;
        configData.maximumDepositWithdrawFee = _toWei(10);
        configData.defaultDepositWithdrawFee = _toWei(1);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _transferOwnership(_msgSender());
    }

    function configDevelopmentWallet(address _developmentWallet)
        public
        onlyOwner
    {
        configData.developmentWallet = _developmentWallet;
    }

    function configTokenNameLength(
        uint256 _minimumTokenNameLength,
        uint256 _maximumTokenNameLength
    ) public onlyOwner {
        configData.minimumTokenNameLength = _minimumTokenNameLength;
        configData.maximumTokenNameLength = _maximumTokenNameLength;
    }

    function configStakingApr(
        uint256 _minimumStakingApr,
        uint256 _maximumStakingApr,
        uint256 _defaultStakingApr
    ) public onlyOwner {
        configData.minimumStakingApr = _minimumStakingApr;
        configData.maximumStakingApr = _maximumStakingApr;
        configData.defaultStakingApr = _defaultStakingApr;
    }

    function configStakeUnstakeFees(
        uint256 _minimumStakeUnstakeFee,
        uint256 _maximumStakeUnstakeFee,
        uint256 _defaultStakeUnstakeFee
    ) public onlyOwner {
        configData.minimumStakeUnstakeFee = _minimumStakeUnstakeFee;
        configData.maximumStakeUnstakeFee = _maximumStakeUnstakeFee;
        configData.defaultStakeUnstakeFee = _defaultStakeUnstakeFee;
    }

    function configDepositWithdrawFees(
        uint256 _minimumDepositWithdrawFee,
        uint256 _maximumDepositWithdrawFee,
        uint256 _defaultDepositWithdrawFee
    ) public onlyOwner {
        configData.minimumDepositWithdrawFee = _minimumDepositWithdrawFee;
        configData.maximumDepositWithdrawFee = _maximumDepositWithdrawFee;
        configData.defaultDepositWithdrawFee = _defaultDepositWithdrawFee;
    }

    function excludeFromFees(address _address) public onlyOwner {
        isExcludedFromFees[_address] = true;
    }

    function includeInFees(address _address) public onlyOwner {
        isExcludedFromFees[_address] = false;
    }

    function transferToken(
        address _token,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }

    function _toWei(uint256 _number) internal pure returns (uint256) {
        return _number * (10**18);
    }

    function _fromWei(uint256 _number) internal pure returns (uint256) {
        return _number / (10**18);
    }

    function _secondsToYears(uint256 _seconds) internal pure returns (uint256) {
        return _fromWei(_seconds * (0.0000000317098 * (10**18)));
    }

    function _calculatePercentage(
        uint256 _percentageValue,
        uint256 _totalAmount
    ) internal pure returns (uint256) {
        return (_totalAmount / _toWei(100)) * _percentageValue;
    }

    function configTokenCategory(uint256 _number, string memory _name)
        public
        onlyOwner
    {
        tokenCategory[_number] = _name;
    }

    function tokenExists(address _token) public view returns (bool) {
        for (uint256 tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++) {
            if (tokens[tokenIndex] == _token) return true;
        }
        return false;
    }

    function getTokens() public view returns (address[] memory) {
        return tokens;
    }

    function getTokenData(address _token)
        public
        view
        returns (TokenDetails memory)
    {
        return tokensData[_token];
    }

    function getTokenRewardValue(address _token) public view returns (uint256) {
        return
            _fromWei(
                tokensData[_token].rewardBalance * tokensData[_token].price
            );
    }

    function setTokenPrice(address _token, uint256 _price) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].price = _price;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenAdmin(address _token, address _admin) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        if (tokensData[_token].admin != owner())
            revokeRole(_toRole(_token), tokensData[_token].admin);
        tokensData[_token].admin = _admin;
        tokensData[_token].timestampLastUpdated = block.timestamp;
        grantRole(_toRole(_token), tokensData[_token].admin);
    }

    function setTokenDevDepositWithdrawFees(
        address _token,
        uint256 _devDepositFee,
        uint256 _devWithdrawFee
    ) public onlyOwner {
        _setTokenDepositWithdrawFees(
            _token,
            _devDepositFee,
            _devWithdrawFee,
            "dev"
        );
    }

    function setTokenDevStakeUnstakeFees(
        address _token,
        uint256 _devStakeFee,
        uint256 _devUnstakeFee
    ) public onlyOwner {
        _setTokenStakeUnstakeFees(_token, _devStakeFee, _devUnstakeFee, "dev");
    }

    function verifyToken(address _token) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].isVerified = true;
    }

    function unverifyToken(address _token) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].isVerified = false;
    }

    function addToken(
        address _token,
        string memory _name,
        uint256 _category,
        uint256 _stakingApr,
        uint256 _adminStakeFee,
        uint256 _adminUnstakeFee,
        address _rewardToken
    ) public {
        require(!tokenExists(_token), "Token already exists.");
        _setupRole(_toRole(_token), owner());
        _setupRole(_toRole(_token), _msgSender());
        // uint256 index = tokens.length;
        tokens.push(_token);
        // tokensData[_token].index = index;
        tokensData[_token].category = _category;
        tokensData[_token].admin = _msgSender();
        tokensData[_token].fees.devDepositFee = 1; // in wei
        tokensData[_token].fees.devWithdrawFee = 1; // in wei
        tokensData[_token].fees.devStakeFee = 1; // in wei
        tokensData[_token].fees.devUnstakeFee = 1; // in wei
        tokensData[_token].timestampAdded = block.timestamp;
        setTokenName(_token, _name);
        setTokenStakingApr(_token, _stakingApr);
        setTokenRewardToken(_token, _rewardToken);
        setTokenAdminStakeUnstakeFees(_token, _adminStakeFee, _adminUnstakeFee);
    }

    function activateToken(address _token) public onlyRole(_toRole(_token)) {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].isActive = true;
    }

    function deactivateToken(address _token) public onlyRole(_toRole(_token)) {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].isActive = false;
    }

    function excludeFromTokenAdminFees(address _token, address _address)
        public
        onlyRole(_toRole(_token))
    {
        isExcludedFromTokenAdminFees[_token][_address] = true;
    }

    function includeInTokenAdminFees(address _token, address _address)
        public
        onlyRole(_toRole(_token))
    {
        isExcludedFromTokenAdminFees[_token][_address] = false;
    }

    function setTokenName(address _token, string memory _name)
        public
        onlyRole(_toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(
            bytes(_name).length >= configData.minimumTokenNameLength &&
                bytes(_name).length <= configData.maximumTokenNameLength,
            string.concat(
                "Token name length must be between ",
                Strings.toString(configData.minimumTokenNameLength),
                " and ",
                Strings.toString(configData.maximumTokenNameLength),
                "."
            )
        );
        tokensData[_token].name = _name;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenCategory(address _token, uint256 _category)
        public
        onlyRole(_toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].category = _category;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenStakingApr(address _token, uint256 _stakingApr)
        public
        onlyRole(_toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(
            _stakingApr >= configData.minimumStakingApr &&
                _stakingApr <= configData.maximumStakingApr,
            string.concat(
                "Staking APR must be between ",
                Strings.toString(_fromWei(configData.minimumStakingApr)),
                "% and ",
                Strings.toString(_fromWei(configData.maximumStakingApr)),
                "%."
            )
        );
        tokensData[_token].stakingApr = _stakingApr;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenRewardToken(address _token, address _reward_token)
        public
        onlyRole(_toRole(_token))
        onlyRole(_toRole(_reward_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(tokenExists(_reward_token), "Reward token does not exist.");
        tokensData[_token].rewardToken = _reward_token;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenAdminStakeUnstakeFees(
        address _token,
        uint256 _adminStakeFee,
        uint256 _adminUnstakeFee
    ) public onlyRole(_toRole(_token)) {
        _setTokenStakeUnstakeFees(
            _token,
            _adminStakeFee,
            _adminUnstakeFee,
            "admin"
        );
    }

    function enableTokenMultiTokenRewards(address _token)
        public
        onlyRole(_toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(tokensData[_token].isVerified, "Token not verified.");
        tokensData[_token].hasMultiTokenRewards = true;
    }

    function disableTokenMultiTokenRewards(address _token)
        public
        onlyRole(_toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].hasMultiTokenRewards = false;
    }

    function depositToken(address _token, uint256 _amount)
        public
        onlyRole(_toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            IERC20(_token).balanceOf(_msgSender()) >= _amount,
            "Insufficient wallet balance."
        );

        (
            uint256 devDepositFeeAmount,
            uint256 adminDepositFeeAmount
        ) = getTokenFeeAmounts(_token, _amount, "deposit");
        if (devDepositFeeAmount != 0)
            IERC20(_token).transferFrom(
                _msgSender(),
                configData.developmentWallet,
                devDepositFeeAmount
            );
        uint256 depositAmount = _amount - devDepositFeeAmount;
        IERC20(_token).transferFrom(_msgSender(), address(this), depositAmount);
        tokensData[_token].rewardBalance += depositAmount;
    }

    function withdrawToken(address _token, uint256 _amount)
        public
        onlyRole(_toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            tokensData[_token].rewardBalance >= _amount,
            "Insufficient reward balance."
        );

        tokensData[_token].rewardBalance -= _amount;
        (
            uint256 devWithdrawFeeAmount,
            uint256 adminWithdrawFeeAmount
        ) = getTokenFeeAmounts(_token, _amount, "withdraw");
        if (devWithdrawFeeAmount != 0)
            IERC20(_token).transfer(
                configData.developmentWallet,
                devWithdrawFeeAmount
            );
        uint256 withdrawAmount = _amount - devWithdrawFeeAmount;
        IERC20(_token).transfer(_msgSender(), withdrawAmount);
    }

    function getTokenFeeAmounts(
        address _token,
        uint256 _amount,
        string memory _action
    ) public view returns (uint256, uint256) {
        require(tokenExists(_token), "Token does not exist.");
        require(_amount > 0, "Amount must be greater than zero.");

        uint256 devFee;
        uint256 adminFee;
        if (
            keccak256(abi.encodePacked(_action)) ==
            keccak256(abi.encodePacked("deposit"))
        ) {
            devFee = (tokensData[_token].fees.devDepositFee > 1) /* in wei */
                ? tokensData[_token].fees.devDepositFee
                : configData.defaultDepositWithdrawFee;
        } else if (
            keccak256(abi.encodePacked(_action)) ==
            keccak256(abi.encodePacked("withdraw"))
        ) {
            devFee = (tokensData[_token].fees.devWithdrawFee > 1) /* in wei */
                ? tokensData[_token].fees.devWithdrawFee
                : configData.defaultDepositWithdrawFee;
        } else if (
            keccak256(abi.encodePacked(_action)) ==
            keccak256(abi.encodePacked("stake"))
        ) {
            devFee = (tokensData[_token].fees.devStakeFee > 1) /* in wei */
                ? tokensData[_token].fees.devStakeFee
                : configData.defaultStakeUnstakeFee;
            adminFee = (tokensData[_token].fees.adminStakeFee > 1) /* in wei */
                ? tokensData[_token].fees.adminStakeFee
                : configData.defaultStakeUnstakeFee;
        } else if (
            keccak256(abi.encodePacked(_action)) ==
            keccak256(abi.encodePacked("unstake"))
        ) {
            devFee = (tokensData[_token].fees.devUnstakeFee > 1) /* in wei */
                ? tokensData[_token].fees.devUnstakeFee
                : configData.defaultStakeUnstakeFee;
            adminFee = (tokensData[_token].fees.adminUnstakeFee > 1) /* in wei */
                ? tokensData[_token].fees.adminUnstakeFee
                : configData.defaultStakeUnstakeFee;
        }

        uint256 devFeeAmount = _calculatePercentage(devFee, _amount);
        uint256 adminFeeAmount = _calculatePercentage(adminFee, _amount);
        bool isExcludedFromFee = isExcludedFromFees[_msgSender()];
        bool isExcludedFromAdminFee = isExcludedFromTokenAdminFees[_token][
            _msgSender()
        ];
        if (isExcludedFromFee) {
            devFeeAmount = 0;
            adminFeeAmount = 0;
        } else if (isExcludedFromAdminFee) {
            adminFeeAmount = 0;
        }

        return (devFeeAmount, adminFeeAmount);
    }

    function _setTokenDepositWithdrawFees(
        address _token,
        uint256 _depositFee,
        uint256 _withdrawFee,
        string memory _for
    ) internal {
        require(tokenExists(_token), "Token does not exist.");
        require(
            _depositFee >= configData.minimumDepositWithdrawFee &&
                _depositFee <= configData.maximumDepositWithdrawFee,
            string.concat(
                "Deposit fee must be between ",
                Strings.toString(
                    _fromWei(configData.minimumDepositWithdrawFee)
                ),
                "% and ",
                Strings.toString(
                    _fromWei(configData.maximumDepositWithdrawFee)
                ),
                "%."
            )
        );
        require(
            _withdrawFee >= configData.minimumDepositWithdrawFee &&
                _withdrawFee <= configData.maximumDepositWithdrawFee,
            string.concat(
                "Withdraw fee must be between ",
                Strings.toString(
                    _fromWei(configData.minimumDepositWithdrawFee)
                ),
                "% and ",
                Strings.toString(
                    _fromWei(configData.maximumDepositWithdrawFee)
                ),
                "%."
            )
        );

        if (
            keccak256(abi.encodePacked(_for)) ==
            keccak256(abi.encodePacked("dev"))
        ) {
            tokensData[_token].fees.devDepositFee = _depositFee;
            tokensData[_token].fees.devWithdrawFee = _withdrawFee;
        } else if (
            keccak256(abi.encodePacked(_for)) ==
            keccak256(abi.encodePacked("admin"))
        ) {
            // tokensData[_token].fees.adminDepositFee = _depositFee;
            // tokensData[_token].fees.adminWithdrawFee = _withdrawFee;
        }
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function _setTokenStakeUnstakeFees(
        address _token,
        uint256 _stakeFee,
        uint256 _unstakeFee,
        string memory _for
    ) internal {
        require(tokenExists(_token), "Token does not exist.");
        require(
            _stakeFee >= configData.minimumStakeUnstakeFee &&
                _stakeFee <= configData.maximumStakeUnstakeFee,
            string.concat(
                "Stake fee must be between ",
                Strings.toString(_fromWei(configData.minimumStakeUnstakeFee)),
                "% and ",
                Strings.toString(_fromWei(configData.maximumStakeUnstakeFee)),
                "%."
            )
        );
        require(
            _unstakeFee >= configData.minimumStakeUnstakeFee &&
                _unstakeFee <= configData.maximumStakeUnstakeFee,
            string.concat(
                "Unstake fee must be between ",
                Strings.toString(_fromWei(configData.minimumStakeUnstakeFee)),
                "% and ",
                Strings.toString(_fromWei(configData.maximumStakeUnstakeFee)),
                "%."
            )
        );

        if (
            keccak256(abi.encodePacked(_for)) ==
            keccak256(abi.encodePacked("dev"))
        ) {
            tokensData[_token].fees.devStakeFee = _stakeFee;
            tokensData[_token].fees.devUnstakeFee = _unstakeFee;
        } else if (
            keccak256(abi.encodePacked(_for)) ==
            keccak256(abi.encodePacked("admin"))
        ) {
            tokensData[_token].fees.adminStakeFee = _stakeFee;
            tokensData[_token].fees.adminUnstakeFee = _unstakeFee;
        }
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function _toRole(address a) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(a));
    }

    function stakerExists(address _staker) public view returns (bool) {
        for (
            uint256 stakerIndex = 0;
            stakerIndex < stakers.length;
            stakerIndex++
        ) {
            if (stakers[stakerIndex] == _staker) return true;
        }
        return false;
    }

    function getStakers() public view returns (address[] memory) {
        return stakers;
    }

    function getStakerData(address _staker)
        public
        view
        returns (StakerDetails memory)
    {
        return stakersData[_staker];
    }

    function _addStaker(address _staker) internal {
        require(!stakerExists(_staker), "Staker already exists.");
        // uint256 index = stakers.length;
        stakers.push(_staker);
        // stakersData[_staker].index = index;
        stakersData[_staker].timestampAdded = block.timestamp;
    }

    function getTokenStakerData(address _token, address _staker)
        public
        view
        returns (TokenStakerDetails memory)
    {
        return tokensStakersData[_token][_staker];
    }

    function getStakingValue(address _token, address _staker)
        public
        view
        returns (uint256)
    {
        return
            _fromWei(
                tokensStakersData[_token][_staker].stakingBalance *
                    tokensData[_token].price
            );
    }

    function setStakingRewardToken(address _token, address _reward_token)
        public
    {
        _setStakingRewardToken(_msgSender(), _token, _reward_token, true);
    }

    function stakeToken(address _token, uint256 _amount) public {
        require(tokensData[_token].isActive, "Token not active.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            IERC20(_token).balanceOf(_msgSender()) >= _amount,
            "Insufficient wallet balance."
        );

        (
            uint256 devStakeFeeAmount,
            uint256 adminStakeFeeAmount
        ) = getTokenFeeAmounts(_token, _amount, "stake");
        if (devStakeFeeAmount != 0)
            IERC20(_token).transferFrom(
                _msgSender(),
                configData.developmentWallet,
                devStakeFeeAmount
            );
        if (adminStakeFeeAmount != 0)
            IERC20(_token).transferFrom(
                _msgSender(),
                tokensData[_token].admin,
                adminStakeFeeAmount
            );
        uint256 stakeAmount = _amount -
            (devStakeFeeAmount + adminStakeFeeAmount);
        IERC20(_token).transferFrom(_msgSender(), address(this), stakeAmount);

        if (tokensStakersData[_token][_msgSender()].stakingBalance == 0) {
            if (stakersData[_msgSender()].uniqueTokensStaked == 0) {
                if (!stakerExists(_msgSender())) _addStaker(_msgSender());
                stakersData[_msgSender()].isActive = true;
            }

            stakersData[_msgSender()].uniqueTokensStaked++;
            stakersData[_msgSender()].timestampAdded == 0
                ? stakersData[_msgSender()].timestampAdded = block.timestamp
                : stakersData[_msgSender()].timestampLastUpdated = block
                .timestamp;

            if (
                tokensStakersData[_token][_msgSender()].stakingRewardToken ==
                address(0x0)
            )
                tokensStakersData[_token][_msgSender()]
                    .stakingRewardToken = tokensData[_token].rewardToken;
        } else {
            _issueStakingReward(
                _token,
                _msgSender(),
                ["stake", Strings.toString(_fromWei(_amount))]
            );
        }

        tokensStakersData[_token][_msgSender()].stakingBalance += stakeAmount;
        tokensStakersData[_token][_msgSender()].timestampAdded == 0
            ? tokensStakersData[_token][_msgSender()].timestampAdded = block
                .timestamp
            : tokensStakersData[_token][_msgSender()]
                .timestampLastUpdated = block.timestamp;
        tokensData[_token].stakingBalance += stakeAmount;
        tokensData[_token].timestampLastUpdated = block.timestamp;

        // emit Stake(_msgSender(), _token, stakeAmount);
    }

    function unstakeToken(address _token, uint256 _amount) public {
        require(tokenExists(_token), "Token does not exist.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            tokensStakersData[_token][_msgSender()].stakingBalance >= _amount,
            "Insufficient staking balance."
        );

        _issueStakingReward(
            _token,
            _msgSender(),
            ["unstake", Strings.toString(_fromWei(_amount))]
        );

        if (tokensStakersData[_token][_msgSender()].stakingBalance == _amount) {
            if (stakersData[_msgSender()].uniqueTokensStaked == 1) {
                stakersData[_msgSender()].isActive = false;
            }
            stakersData[_msgSender()].uniqueTokensStaked--;
            stakersData[_msgSender()].timestampLastUpdated = block.timestamp;
        }

        tokensStakersData[_token][_msgSender()].stakingBalance -= _amount;
        tokensStakersData[_token][_msgSender()].timestampLastUpdated = block
            .timestamp;
        tokensData[_token].stakingBalance -= _amount;
        tokensData[_token].timestampLastUpdated = block.timestamp;

        (
            uint256 devUnstakeFeeAmount,
            uint256 adminUnstakeFeeAmount
        ) = getTokenFeeAmounts(_token, _amount, "unstake");
        if (devUnstakeFeeAmount != 0)
            IERC20(_token).transfer(
                configData.developmentWallet,
                devUnstakeFeeAmount
            );
        if (adminUnstakeFeeAmount != 0)
            IERC20(_token).transfer(
                tokensData[_token].admin,
                adminUnstakeFeeAmount
            );
        uint256 unstakeAmount = _amount -
            (devUnstakeFeeAmount + adminUnstakeFeeAmount);
        IERC20(_token).transfer(_msgSender(), unstakeAmount);

        // emit Unstake(_msgSender(), _token, unstakeAmount);
    }

    function claimStakingReward(address _token) public {
        require(tokensData[_token].isActive, "Token not active.");
        _issueStakingReward(_token, _msgSender(), ["claim staking reward", ""]);
    }

    function withdrawStakingReward(address _reward_token, uint256 _amount)
        public
    {
        require(tokenExists(_reward_token), "Reward token does not exist.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            tokensStakersData[_reward_token][_msgSender()].rewardBalance >=
                _amount,
            "Insufficient reward balance."
        );
        tokensStakersData[_reward_token][_msgSender()].rewardBalance -= _amount;
        tokensStakersData[_reward_token][_msgSender()]
            .timestampLastUpdated = block.timestamp;
        IERC20(_reward_token).transfer(_msgSender(), _amount);
        // emit WithdrawStakingReward(_msgSender(), _reward_token, _amount);
    }

    function _setStakingRewardToken(
        address _staker,
        address _token,
        address _reward_token,
        bool validate
    ) internal returns (address stakingRewardToken) {
        if (validate) {
            require(tokensData[_token].isActive, "Token not active.");
            require(
                tokensData[_token].hasMultiTokenRewards,
                "Token does not have multi token rewards."
            );
            require(
                tokensData[_reward_token].isActive,
                "Reward token not active."
            );
            require(
                tokensData[_reward_token].hasMultiTokenRewards,
                "Reward token does not have multi token rewards."
            );
        }

        if (!stakerExists(_staker)) _addStaker(_staker);
        tokensStakersData[_token][_staker].stakingRewardToken = _reward_token;
        tokensStakersData[_token][_staker].timestampLastUpdated = block
            .timestamp;
        return tokensStakersData[_token][_staker].stakingRewardToken;
    }

    function _issueStakingReward(
        address _token,
        address _staker,
        string[2] memory _triggeredBy
    ) internal {
        // if (!tokensData[_token].isActive) return;
        // if (!stakersData[_staker].isActive) return;
        // (
        //     uint256 stakingRewardValue,
        //     uint256 stakingDurationInSeconds,
        //     uint256 stakingApr,
        //     uint256 stakingBalance,
        //     uint256 tokenPrice
        // ) = Lib.calculateStakingReward(this, _token, _staker);
        // if (stakingRewardValue == 0) return;
        // address tokenRewardToken = tokensData[_token].rewardToken;
        // if (!tokensData[tokenRewardToken].isActive) return;
        // uint256 tokenRewardTokenRewardValue = getTokenRewardValue(
        //     tokenRewardToken
        // );
        // if (tokenRewardTokenRewardValue < stakingRewardValue) {
        //     deactivateToken(_token);
        //     return;
        // }
        // address rewardToken = tokenRewardToken;
        // uint256 rewardTokenPrice = tokensData[rewardToken].price;
        // uint256 rewardTokenAmount = _toWei(stakingRewardValue) /
        //     rewardTokenPrice;
        // {
        //     // if staking reward token is different from token reward token,
        //     // staking reward token admin receives the reward in token reward token
        //     // to pay back equivalent in staking reward token, basically swapping
        //     address stakingRewardToken = tokensStakersData[_token][_staker]
        //         .stakingRewardToken;
        //     if (stakingRewardToken != rewardToken) {
        //         if (tokensData[stakingRewardToken].isActive) {
        //             uint256 stakingRewardTokenRewardValue = getTokenRewardValue(
        //                 stakingRewardToken
        //             );
        //             if (!(stakingRewardTokenRewardValue < stakingRewardValue)) {
        //                 // staking reward token admin receives the reward
        //                 // in token reward token
        //                 address stakingRewardTokenAdmin = tokensData[
        //                     stakingRewardToken
        //                 ].admin;
        //                 tokensData[rewardToken]
        //                     .rewardBalance -= rewardTokenAmount;
        //                 tokensData[rewardToken].timestampLastUpdated = block
        //                     .timestamp;
        //                 tokensStakersData[rewardToken][stakingRewardTokenAdmin]
        //                     .rewardBalance += rewardTokenAmount;
        //                 tokensStakersData[rewardToken][stakingRewardTokenAdmin]
        //                     .timestampLastUpdated = block.timestamp;
        //                 // change reward token to staking reward token for payback
        //                 rewardToken = stakingRewardToken;
        //                 rewardTokenPrice = tokensData[rewardToken].price;
        //                 rewardTokenAmount =
        //                     _toWei(stakingRewardValue) /
        //                     rewardTokenPrice;
        //             }
        //         }
        //     }
        // }
        // tokensData[rewardToken].rewardBalance -= rewardTokenAmount;
        // tokensData[rewardToken].timestampLastUpdated = block.timestamp;
        // tokensStakersData[rewardToken][_staker]
        //     .rewardBalance += rewardTokenAmount;
        // tokensStakersData[rewardToken][_staker].timestampLastUpdated = block
        //     .timestamp;
        // tokensStakersData[_token][_staker].timestampLastRewarded = block
        //     .timestamp;
        // TokenStakerRewardDetails memory tokenStakerRewardData;
        // tokenStakerRewardData.id = tokensStakersData[_token][_staker]
        //     .stakingRewards
        //     .length;
        // tokenStakerRewardData.staker = _staker;
        // tokenStakerRewardData.rewardToken = rewardToken;
        // tokenStakerRewardData.rewardTokenPrice = rewardTokenPrice;
        // tokenStakerRewardData.rewardTokenAmount = rewardTokenAmount;
        // tokenStakerRewardData.stakedToken = _token;
        // tokenStakerRewardData.stakedTokenPrice = tokenPrice;
        // tokenStakerRewardData.stakedTokenAmount = stakingBalance;
        // tokenStakerRewardData.stakingApr = stakingApr;
        // tokenStakerRewardData
        //     .stakingDurationInSeconds = stakingDurationInSeconds;
        // tokenStakerRewardData.triggeredBy = _triggeredBy;
        // tokenStakerRewardData.timestampAdded = block.timestamp;
        // tokensStakersData[_token][_staker].stakingRewards.push(
        //     tokenStakerRewardData
        // );
        // emit IssueStakingReward(_staker, _token, tokenStakerRewardData);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "IAccessControl.sol";
import "Context.sol";
import "Strings.sol";
import "ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
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
pragma solidity ^0.8.0;

import "SavvyFinanceFarm.sol";

library SavvyFinanceFarmLibrary {
    function toWei(uint256 _number) public pure returns (uint256) {
        return _number * (10**18);
    }

    function fromWei(uint256 _number) public pure returns (uint256) {
        return _number / (10**18);
    }

    function secondsToYears(uint256 _seconds) public pure returns (uint256) {
        return fromWei(_seconds * (0.0000000317098 * (10**18)));
    }

    function calculatePercentage(uint256 _percentageValue, uint256 _totalAmount)
        public
        pure
        returns (uint256)
    {
        return (_totalAmount / toWei(100)) * _percentageValue;
    }

    function calculateStakingReward(
        SavvyFinanceFarm farm,
        address _token,
        address _staker
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (!farm.tokenExists(_token)) return (0, 0, 0, 0, 0);
        if (!farm.stakerExists(_staker)) return (0, 0, 0, 0, 0);

        uint256 tokenPrice = farm.getTokenData(_token).price;
        uint256 stakingBalance = farm
            .getTokenStakerData(_token, _staker)
            .stakingBalance;
        uint256 stakingValue = fromWei(stakingBalance * tokenPrice);
        if (stakingValue <= 0) return (0, 0, 0, 0, 0);

        uint256 stakingApr = farm.getTokenData(_token).stakingApr;
        uint256 stakingRewardRate = stakingApr / 100;
        uint256 stakingTimestampLastRewarded = farm
            .getTokenStakerData(_token, _staker)
            .timestampLastRewarded;
        uint256 stakingTimestampStarted = stakingTimestampLastRewarded != 0
            ? stakingTimestampLastRewarded
            : farm.getTokenStakerData(_token, _staker).timestampAdded;
        uint256 stakingTimestampEnded = block.timestamp;
        uint256 stakingDurationInSeconds = toWei(
            stakingTimestampEnded - stakingTimestampStarted
        );
        uint256 stakingDurationInYears = secondsToYears(
            stakingDurationInSeconds
        );
        uint256 stakingRewardValue = (stakingValue *
            stakingRewardRate *
            stakingDurationInYears) / (10**36);

        return (
            stakingRewardValue,
            stakingDurationInSeconds,
            stakingApr,
            stakingBalance,
            tokenPrice
        );
    }
}