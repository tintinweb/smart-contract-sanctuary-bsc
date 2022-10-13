// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./SafeMathUInt128.sol";
import "./SafeMathUInt32.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "./Events.sol";
import "./Utils.sol";
import "./Bytes.sol";
import "./TxTypes.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./NFTFactory.sol";
import "./Config.sol";
import "./ZNSController.sol";
import "./Proxy.sol";
import "./UpgradeableMaster.sol";
import "./Storage.sol";

/// @title ZkBNB main contract
/// @author ZkBNB Team
contract ZkBNB is UpgradeableMaster, Events, Storage, Config, ReentrancyGuardUpgradeable, IERC721Receiver {
    using SafeMath for uint256;
    using SafeMathUInt128 for uint128;
    using SafeMathUInt32 for uint32;

    bytes32 private constant EMPTY_STRING_KECCAK = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    struct CommitBlockInfo {
        bytes32 newStateRoot;
        bytes publicData;
        uint256 timestamp;
        uint32[] publicDataOffsets;
        uint32 blockNumber;
        uint16 blockSize;
    }

    struct VerifyAndExecuteBlockInfo {
        StoredBlockInfo blockHeader;
        bytes[] pendingOnchainOpsPubData;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4){
        return this.onERC721Received.selector;
    }

    // Upgrade functional
    /// @notice Shortest Notice period before activation preparation status of upgrade mode
    ///         Notice period can be set by secure council
    function getNoticePeriod() external pure override returns (uint256) {
        return SHORTEST_UPGRADE_NOTICE_PERIOD;
    }

    /// @notice Notification that upgrade notice period started
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradeNoticePeriodStarted() external override {
        upgradeStartTimestamp = block.timestamp;
    }

    /// @notice Notification that upgrade preparation status is activated
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradePreparationStarted() external override {
        upgradePreparationActive = true;
        upgradePreparationActivationTime = block.timestamp;
        // Check if the approvedUpgradeNoticePeriod is passed
        require(block.timestamp >= upgradeStartTimestamp.add(approvedUpgradeNoticePeriod));
    }

    /// @dev When upgrade is finished or canceled we must clean upgrade-related state.
    function clearUpgradeStatus() internal {
        upgradePreparationActive = false;
        upgradePreparationActivationTime = 0;
        approvedUpgradeNoticePeriod = UPGRADE_NOTICE_PERIOD;
        emit NoticePeriodChange(approvedUpgradeNoticePeriod);
        upgradeStartTimestamp = 0;
        for (uint256 i = 0; i < SECURITY_COUNCIL_MEMBERS_NUMBER; ++i) {
            securityCouncilApproves[i] = false;
        }
        numberOfApprovalsFromSecurityCouncil = 0;
    }

    /// @notice Notification that upgrade canceled
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradeCanceled() external override {
        clearUpgradeStatus();
    }

    /// @notice Notification that upgrade finishes
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradeFinishes() external override {
        clearUpgradeStatus();
    }

    /// @notice Checks that contract is ready for upgrade
    /// @return bool flag indicating that contract is ready for upgrade
    function isReadyForUpgrade() external view override returns (bool) {
        return !desertMode;
    }

    function upgrade(bytes calldata upgradeParameters) external {}

    function cutUpgradeNoticePeriod() external {
        /// All functions delegated to additional contract should NOT be nonReentrant
        delegateAdditional();
    }

    /// @notice Checks if Desert mode must be entered. If true - enters exodus mode and emits ExodusMode event.
    /// @dev Desert mode must be entered in case of current ethereum block number is higher than the oldest
    /// @dev of existed priority requests expiration block number.
    /// @return bool flag that is true if the Exodus mode must be entered.
    function activateDesertMode() public returns (bool) {
        // #if EASY_DESERT
        bool trigger = true;
        // #else
        trigger = block.number >= priorityRequests[firstPriorityRequestId].expirationBlock &&
        priorityRequests[firstPriorityRequestId].expirationBlock != 0;
        // #endif
        if (trigger) {
            if (!desertMode) {
                desertMode = true;
                emit DesertMode();
            }
            return true;
        } else {
            return false;
        }
    }

    /// @notice ZkBNB contract initialization. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param initializationParameters Encoded representation of initialization parameters:
    /// @dev _governanceAddress The address of Governance contract
    /// @dev _verifierAddress The address of Verifier contract
    /// @dev _genesisStateHash Genesis blocks (first block) state tree root hash
    function initialize(bytes calldata initializationParameters) external initializer {
        __ReentrancyGuard_init();

        (
        address _governanceAddress,
        address _verifierAddress,
        address _additionalZkBNB,
        address _znsController,
        address _znsResolver,
        bytes32 _genesisStateRoot
        ) = abi.decode(initializationParameters, (address, address, address, address, address, bytes32));

        verifier = ZkBNBVerifier(_verifierAddress);
        governance = Governance(_governanceAddress);
        additionalZkBNB = AdditionalZkBNB(_additionalZkBNB);
        znsController = ZNSController(_znsController);
        znsResolver = PublicResolver(_znsResolver);

        StoredBlockInfo memory zeroStoredBlockInfo = StoredBlockInfo(
            0,
            0,
            0,
            EMPTY_STRING_KECCAK,
            0,
            _genesisStateRoot,
            bytes32(0)
        );
        stateRoot = _genesisStateRoot;
        storedBlockHashes[0] = hashStoredBlockInfo(zeroStoredBlockInfo);
        approvedUpgradeNoticePeriod = UPGRADE_NOTICE_PERIOD;
        emit NoticePeriodChange(approvedUpgradeNoticePeriod);
    }

    function registerZNS(string calldata _name, address _owner, bytes32 _zkbnbPubKeyX, bytes32 _zkbnbPubKeyY) external payable nonReentrant {
        // Register ZNS
        (bytes32 node,uint32 accountIndex) = znsController.registerZNS{value : msg.value}(_name, _owner, _zkbnbPubKeyX, _zkbnbPubKeyY, address(znsResolver));

        // Priority Queue request
        TxTypes.RegisterZNS memory _tx = TxTypes.RegisterZNS({
        txType : uint8(TxTypes.TxType.RegisterZNS),
        accountIndex : accountIndex,
        accountName : Utils.stringToBytes32(_name),
        accountNameHash : node,
        pubKeyX : _zkbnbPubKeyX,
        pubKeyY : _zkbnbPubKeyY
        });
        // compact pub data
        bytes memory pubData = TxTypes.writeRegisterZNSPubDataForPriorityQueue(_tx);

        // add into priority request queue
        addPriorityRequest(TxTypes.TxType.RegisterZNS, pubData);

        emit RegisterZNS(_name, node, _owner, _zkbnbPubKeyX, _zkbnbPubKeyY, accountIndex);
    }

    function isRegisteredZNSName(string memory _name) external view returns (bool) {
        return znsController.isRegisteredZNSName(_name);
    }

    function getZNSNamePrice(string calldata name) external view returns (uint256) {
        return znsController.getZNSNamePrice(name);
    }

    function getAddressByAccountNameHash(bytes32 accountNameHash) public view returns (address){
        return znsController.getOwner(accountNameHash);
    }

    /// @notice Deposit Native Assets to Layer 2 - transfer ether from user into contract, validate it, register deposit
    /// @param _accountName the receiver account name
    function depositBNB(string calldata _accountName) external payable {
        require(msg.value != 0, "ia");
        requireActive();
        bytes32 accountNameHash = znsController.getSubnodeNameHash(_accountName);
        require(znsController.isRegisteredNameHash(accountNameHash), "nr");
        registerDeposit(0, SafeCast.toUint128(msg.value), accountNameHash);
    }

    /// @notice Deposit or Lock BEP20 token to Layer 2 - transfer ERC20 tokens from user into contract, validate it, register deposit
    /// @param _token Token address
    /// @param _amount Token amount
    /// @param _accountName Receiver Layer 2 account name
    function depositBEP20(
        IERC20 _token,
        uint104 _amount,
        string calldata _accountName
    ) external {
        require(_amount != 0, "I");
        requireActive();
        bytes32 accountNameHash = znsController.getSubnodeNameHash(_accountName);
        require(znsController.isRegisteredNameHash(accountNameHash), "N");
        // Get asset id by its address
        uint16 assetId = governance.validateAssetAddress(address(_token));
        require(!governance.pausedAssets(assetId), "b");
        // token deposits are paused

        uint256 balanceBefore = _token.balanceOf(address(this));
        require(Utils.transferFromERC20(_token, msg.sender, address(this), SafeCast.toUint128(_amount)), "c");
        // token transfer failed deposit
        uint256 balanceAfter = _token.balanceOf(address(this));
        uint128 depositAmount = SafeCast.toUint128(balanceAfter.sub(balanceBefore));
        require(depositAmount <= MAX_DEPOSIT_AMOUNT, "C");
        require(depositAmount > 0, "D");

        registerDeposit(assetId, depositAmount, accountNameHash);
    }

    /// @notice Deposit NFT to Layer 2, ERC721 is supported
    function depositNft(
        string calldata _accountName,
        address _nftL1Address,
        uint256 _nftL1TokenId
    ) external {
        requireActive();
        bytes32 accountNameHash = znsController.getSubnodeNameHash(_accountName);
        require(znsController.isRegisteredNameHash(accountNameHash), "nr");
        // Transfer the tokens to this contract
        bool success;
        try IERC721(_nftL1Address).safeTransferFrom(
            msg.sender,
            address(this),
            _nftL1TokenId
        ){
            success = true;
        }catch{
            success = false;
        }
        require(success, "ntf");
        // check owner
        require(IERC721(_nftL1Address).ownerOf(_nftL1TokenId) == address(this), "i");

        // check if the nft is mint from layer-2
        bytes32 nftKey = keccak256(abi.encode(_nftL1Address, _nftL1TokenId));
        require(l2Nfts[nftKey].nftContentHash != bytes32(0), "l1 nft is not allowed");

        bytes32 nftContentHash = l2Nfts[nftKey].nftContentHash;
        uint16 collectionId = l2Nfts[nftKey].collectionId;
        uint40 nftIndex = l2Nfts[nftKey].nftIndex;
        uint32 creatorAccountIndex = l2Nfts[nftKey].creatorAccountIndex;
        uint16 creatorTreasuryRate = l2Nfts[nftKey].creatorTreasuryRate;

        TxTypes.DepositNft memory _tx = TxTypes.DepositNft({
            txType : uint8(TxTypes.TxType.DepositNft),
            accountIndex : 0, // unknown at this point
            nftIndex : nftIndex,
            nftL1Address : _nftL1Address,
            creatorAccountIndex : creatorAccountIndex,
            creatorTreasuryRate : creatorTreasuryRate,
            nftContentHash : nftContentHash,
            nftL1TokenId : _nftL1TokenId,
            accountNameHash : accountNameHash,
            collectionId : collectionId
        });

        // compact pub data
        bytes memory pubData = TxTypes.writeDepositNftPubDataForPriorityQueue(_tx);

        // add into priority request queue
        addPriorityRequest(TxTypes.TxType.DepositNft, pubData);

        emit DepositNft(accountNameHash, nftContentHash, _nftL1Address, _nftL1TokenId, collectionId);
    }

    function withdrawOrStoreNFT(TxTypes.WithdrawNft memory op) internal {
        require(op.nftIndex <= MAX_NFT_INDEX, "invalid nft index");

        // get layer-1 address by account name hash
        bytes memory _emptyExtraData;
        if (op.nftL1Address != address(0x00)) {
            /// This is a NFT from layer 1, withdraw id directly
            try IERC721(op.nftL1Address).safeTransferFrom{gas : WITHDRAWAL_NFT_GAS_LIMIT}(
                address(this),
                op.toAddress,
                op.nftL1TokenId
            ) {
                emit WithdrawNft(op.fromAccountIndex, op.nftL1Address, op.toAddress, op.nftL1TokenId);
            }catch{
                storePendingNFT(op);
            }

            bytes32 nftKey = keccak256(abi.encode(op.nftL1Address, op.nftL1TokenId));
            if (l2Nfts[nftKey].nftContentHash == bytes32(0)) {
                l2Nfts[nftKey] = L2NftInfo({
                nftIndex : op.nftIndex,
                creatorAccountIndex : op.creatorAccountIndex,
                creatorTreasuryRate : op.creatorTreasuryRate,
                nftContentHash : op.nftContentHash,
                collectionId : uint16(op.collectionId)
                });
            }
        } else {
            address _creatorAddress = getAddressByAccountNameHash(op.creatorAccountNameHash);
            // get nft factory
            address _factoryAddress = address(getNFTFactory(op.creatorAccountNameHash, op.collectionId));
            // store into l2 nfts
            bytes32 nftKey = keccak256(abi.encode(_factoryAddress, op.nftIndex));
            l2Nfts[nftKey] = L2NftInfo({
            nftIndex : op.nftIndex,
            creatorAccountIndex : op.creatorAccountIndex,
            creatorTreasuryRate : op.creatorTreasuryRate,
            nftContentHash : op.nftContentHash,
            collectionId : uint16(op.collectionId)
            });
            try NFTFactory(_factoryAddress).mintFromZkBNB(
                _creatorAddress,
                op.toAddress,
                op.nftIndex,
                op.nftContentHash,
                _emptyExtraData
            ) {
                emit WithdrawNft(op.fromAccountIndex, _factoryAddress, op.toAddress, op.nftIndex);
            } catch {
                storePendingNFT(op);
            }
        }
    }

    /// @notice Get a registered NFTFactory according to the creator accountNameHash and the collectionId
    /// @param _creatorAccountNameHash creator account name hash of the factory
    /// @param _collectionId collection id of the nft collection related to this creator
    function getNFTFactory(bytes32 _creatorAccountNameHash, uint32 _collectionId) public view returns (address) {
        address _factoryAddr = nftFactories[_creatorAccountNameHash][_collectionId];
        if (_factoryAddr == address(0)) {
            require(address(defaultNFTFactory) != address(0), "F");
            // NFTFactory does not set
            return defaultNFTFactory;
        } else {
            return _factoryAddr;
        }
    }

    /// @dev Save NFT as pending to withdraw
    function storePendingNFT(TxTypes.WithdrawNft memory op) internal {
        pendingWithdrawnNFTs[op.nftIndex] = op;
        emit WithdrawalNFTPending(op.nftIndex);
    }

    /// @notice  Withdraws NFT from zkSync contract to the owner
    /// @param _nftIndex Id of NFT token
    function withdrawPendingNFTBalance(uint40 _nftIndex) external {
        TxTypes.WithdrawNft memory op = pendingWithdrawnNFTs[_nftIndex];
        withdrawOrStoreNFT(op);
        delete pendingWithdrawnNFTs[_nftIndex];
    }

    /// @notice Get pending balance that the user can withdraw
    /// @param _address The layer-1 address
    /// @param _assetAddr Token address
    function getPendingBalance(address _address, address _assetAddr) public view returns (uint128) {
        uint16 assetId = 0;
        if (_assetAddr != address(0)) {
            assetId = governance.validateAssetAddress(_assetAddr);
        }
        return pendingBalances[packAddressAndAssetId(_address, assetId)].balanceToWithdraw;
    }

    /// @notice  Withdraws tokens from ZkBNB contract to the owner
    /// @param _owner Address of the tokens owner
    /// @param _token Address of tokens, zero address is used for Native Asset
    /// @param _amount Amount to withdraw to request.
    ///         NOTE: We will call ERC20.transfer(.., _amount), but if according to internal logic of ERC20 token ZkBNB contract
    ///         balance will be decreased by value more then _amount we will try to subtract this value from user pending balance
    function withdrawPendingBalance(
        address payable _owner,
        address _token,
        uint128 _amount
    ) external {
        uint16 _assetId = 0;
        if (_token != address(0)) {
            _assetId = governance.validateAssetAddress(_token);
        }
        bytes22 packedBalanceKey = packAddressAndAssetId(_owner, _assetId);
        uint128 balance = pendingBalances[packedBalanceKey].balanceToWithdraw;
        uint128 amount = Utils.minU128(balance, _amount);
        if (_assetId == 0) {
            (bool success,) = _owner.call{value : _amount}("");
            // Native Asset withdraw failed
            require(success, "d");
        } else {
            // We will allow withdrawals of `value` such that:
            // `value` <= user pending balance
            // `value` can be bigger then `_amount` requested if token takes fee from sender in addition to `_amount` requested
            amount = this.transferERC20(IERC20(_token), _owner, amount, balance);
        }
        pendingBalances[packedBalanceKey].balanceToWithdraw = balance - _amount;
        emit Withdrawal(_assetId, _amount);
    }

    /// @notice Sends tokens
    /// @dev NOTE: will revert if transfer call fails or rollup balance difference (before and after transfer) is bigger than _maxAmount
    /// @dev This function is used to allow tokens to spend zkSync contract balance up to amount that is requested
    /// @param _token Token address
    /// @param _to Address of recipient
    /// @param _amount Amount of tokens to transfer
    /// @param _maxAmount Maximum possible amount of tokens to transfer to this account
    function transferERC20(
        IERC20 _token,
        address _to,
        uint128 _amount,
        uint128 _maxAmount
    ) external returns (uint128 withdrawnAmount) {
        require(msg.sender == address(this), "5");
        // can be called only from this contract as one "external" call (to revert all this function state changes if it is needed)

        uint256 balanceBefore = _token.balanceOf(address(this));
        _token.transfer(_to, _amount);
        uint256 balanceAfter = _token.balanceOf(address(this));
        uint256 balanceDiff = balanceBefore.sub(balanceAfter);
        //        require(balanceDiff > 0, "C");
        // transfer is considered successful only if the balance of the contract decreased after transfer
        require(balanceDiff <= _maxAmount, "7");
        // rollup balance difference (before and after transfer) is bigger than `_maxAmount`

        // It is safe to convert `balanceDiff` to `uint128` without additional checks, because `balanceDiff <= _maxAmount`
        return uint128(balanceDiff);
    }

    /// @notice Commit block
    /// @notice 1. Checks onchain operations, timestamp.
    function commitBlocks(
        StoredBlockInfo memory _lastCommittedBlockData,
        CommitBlockInfo[] memory _newBlocksData
    )
    external
    {
        delegateAdditional();
    }

    /// @notice Verify block index and proofs
    function verifyAndExecuteOneBlock(VerifyAndExecuteBlockInfo memory _block, uint32 _verifiedBlockIdx) internal {
        // Ensure block was committed
        require(
            hashStoredBlockInfo(_block.blockHeader) ==
            storedBlockHashes[_block.blockHeader.blockNumber],
            "A" // executing block should be committed
        );
        // blocks must in order
        require(_block.blockHeader.blockNumber == totalBlocksVerified + _verifiedBlockIdx + 1, "k");

        bytes32 pendingOnchainOpsHash = EMPTY_STRING_KECCAK;
        for (uint32 i = 0; i < _block.pendingOnchainOpsPubData.length; ++i) {
            bytes memory pubData = _block.pendingOnchainOpsPubData[i];

            TxTypes.TxType txType = TxTypes.TxType(uint8(pubData[0]));

            if (txType == TxTypes.TxType.Withdraw) {
                TxTypes.Withdraw memory _tx = TxTypes.readWithdrawPubData(pubData);
                // Circuit guarantees that partial exits are available only for fungible tokens
                //                require(_tx.assetId <= MAX_FUNGIBLE_ASSET_ID, "A");
                withdrawOrStore(uint16(_tx.assetId), _tx.toAddress, _tx.assetAmount);
            } else if (txType == TxTypes.TxType.FullExit) {
                TxTypes.FullExit memory _tx = TxTypes.readFullExitPubData(pubData);
                //                require(_tx.assetId <= MAX_FUNGIBLE_ASSET_ID, "B");
                // get layer-1 address by account name hash
                address creatorAddress = getAddressByAccountNameHash(_tx.accountNameHash);
                withdrawOrStore(uint16(_tx.assetId), creatorAddress, _tx.assetAmount);
            } else if (txType == TxTypes.TxType.FullExitNft) {
                TxTypes.FullExitNft memory _tx = TxTypes.readFullExitNftPubData(pubData);
                // get address by account name hash
                address toAddr = getAddressByAccountNameHash(_tx.accountNameHash);
                // withdraw nft
                if (_tx.nftContentHash != bytes32(0)) {
                    TxTypes.WithdrawNft memory _withdrawNftTx = TxTypes.WithdrawNft({
                    txType : uint8(TxTypes.TxType.WithdrawNft),
                    fromAccountIndex : _tx.accountIndex,
                    creatorAccountIndex : _tx.creatorAccountIndex,
                    creatorTreasuryRate : _tx.creatorTreasuryRate,
                    nftIndex : _tx.nftIndex,
                    nftL1Address : _tx.nftL1Address,
                    toAddress : toAddr,
                    gasFeeAccountIndex : 0,
                    gasFeeAssetId : 0,
                    gasFeeAssetAmount : 0,
                    nftContentHash : _tx.nftContentHash,
                    nftL1TokenId : _tx.nftL1TokenId,
                    creatorAccountNameHash : _tx.accountNameHash,
                    collectionId : _tx.collectionId
                    });
                    withdrawOrStoreNFT(_withdrawNftTx);
                }
            } else if (txType == TxTypes.TxType.WithdrawNft) {
                TxTypes.WithdrawNft memory _tx = TxTypes.readWithdrawNftPubData(pubData);
                // withdraw NFT
                withdrawOrStoreNFT(_tx);
            } else {
                // unsupported _tx in block verification
                revert("l");
            }

            pendingOnchainOpsHash = Utils.concatHash(pendingOnchainOpsHash, pubData);
        }
        // incorrect onchain txs executed
        require(pendingOnchainOpsHash == _block.blockHeader.pendingOnchainOperationsHash, "m");
    }

    /// @dev 1. Try to send token to _recipients
    /// @dev 2. On failure: Increment _recipients balance to withdraw.
    function withdrawOrStore(
        uint16 _assetId,
        address _recipient,
        uint128 _amount
    ) internal {
        bytes22 packedBalanceKey = packAddressAndAssetId(_recipient, _assetId);

        bool sent = false;
        if (_assetId == 0) {
            address payable toPayable = address(uint160(_recipient));
            sent = sendBNBNoRevert(toPayable, _amount);
        } else {
            address tokenAddr = governance.assetAddresses(_assetId);
            // We use `_transferERC20` here to check that `ERC20` token indeed transferred `_amount`
            // and fail if token subtracted from ZkBNB balance more then `_amount` that was requested.
            // This can happen if token subtracts fee from sender while transferring `_amount` that was requested to transfer.
            try this.transferERC20{gas : WITHDRAWAL_GAS_LIMIT}(IERC20(tokenAddr), _recipient, _amount, _amount) {
                sent = true;
            } catch {
                sent = false;
            }
        }
        if (sent) {
            emit Withdrawal(_assetId, _amount);
        } else {
            increaseBalanceToWithdraw(packedBalanceKey, _amount);
        }
    }

    /// @notice Verify layer-2 blocks proofs
    /// @param _blocks Verified blocks info
    /// @param _proofs proofs
    function verifyAndExecuteBlocks(VerifyAndExecuteBlockInfo[] memory _blocks, uint256[] memory _proofs) external {
        requireActive();
        governance.requireActiveValidator(msg.sender);

        uint64 priorityRequestsExecuted = 0;
        uint32 nBlocks = uint32(_blocks.length);
        // proof public inputs
        for (uint16 i = 0; i < _blocks.length; ++i) {
            priorityRequestsExecuted += _blocks[i].blockHeader.priorityOperations;
            // update account root
            verifyAndExecuteOneBlock(_blocks[i], i);
            emit BlockVerification(_blocks[i].blockHeader.blockNumber);
        }
        uint numBlocksVerified = 0;
        bool[] memory blockVerified = new bool[](nBlocks);
        uint[] memory batch = new uint[](nBlocks);
        uint firstBlockSize = 0;
        while (numBlocksVerified < nBlocks) {
            // Find all blocks of the same type
            uint batchLength = 0;
            for (uint i = 0; i < nBlocks; i++) {
                if (blockVerified[i] == false) {
                    if (batchLength == 0) {
                        firstBlockSize = _blocks[i].blockHeader.blockSize;
                        batch[batchLength++] = i;
                    } else {
                        if (_blocks[i].blockHeader.blockSize == firstBlockSize) {
                            batch[batchLength++] = i;
                        }
                    }
                }
            }
            // Prepare the data for batch verification
            uint[] memory publicInputs = new uint[](batchLength);
            uint[] memory proofs = new uint[](batchLength * 8);
            uint16 block_size = 0;
            uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
            for (uint i = 0; i < batchLength; i++) {
                uint blockIdx = batch[i];
                blockVerified[blockIdx] = true;
                // verify block proof
                VerifyAndExecuteBlockInfo memory _block = _blocks[blockIdx];
                publicInputs[i] = uint256(_block.blockHeader.commitment) % q;
                for (uint j = 0; j < 8; j++) {
                    proofs[8 * i + j] = _proofs[8 * blockIdx + j];
                }
                block_size = _block.blockHeader.blockSize;
            }
            bool res = verifier.verifyBatchProofs(proofs, publicInputs, batchLength, block_size);
            require(res, "inp");
            numBlocksVerified += batchLength;
        }

        // update account root
        stateRoot = _blocks[nBlocks - 1].blockHeader.stateRoot;
        firstPriorityRequestId += priorityRequestsExecuted;
        totalCommittedPriorityRequests -= priorityRequestsExecuted;
        totalOpenPriorityRequests -= priorityRequestsExecuted;

        totalBlocksVerified += nBlocks;
        // Can't execute blocks more then committed.
        require(totalBlocksVerified <= totalBlocksCommitted, "n");
    }

    /// @notice Register deposit request - pack pubdata, add into onchainOpsCheck and emit OnchainDeposit event
    /// @param _assetId Asset by id
    /// @param _amount Asset amount
    /// @param _accountNameHash Receiver Account Name
    function registerDeposit(
        uint16 _assetId,
        uint128 _amount,
        bytes32 _accountNameHash
    ) internal {
        // Priority Queue request
        TxTypes.Deposit memory _tx = TxTypes.Deposit({
        txType : uint8(TxTypes.TxType.Deposit),
        accountIndex : 0, // unknown at the moment
        accountNameHash : _accountNameHash,
        assetId : _assetId,
        amount : _amount
        });
        // compact pub data
        bytes memory pubData = TxTypes.writeDepositPubDataForPriorityQueue(_tx);
        // add into priority request queue
        addPriorityRequest(TxTypes.TxType.Deposit, pubData);
        emit Deposit(_assetId, _accountNameHash, _amount);
    }

    /// @notice Saves priority request in storage
    /// @dev Calculates expiration block for request, store this request and emit NewPriorityRequest event
    /// @param _txType Rollup _tx type
    /// @param _pubData _tx pub data
    function addPriorityRequest(TxTypes.TxType _txType, bytes memory _pubData) internal {
        // Expiration block is: current block number + priority expiration delta
        uint64 expirationBlock = uint64(block.number + PRIORITY_EXPIRATION);

        uint64 nextPriorityRequestId = firstPriorityRequestId + totalOpenPriorityRequests;

        bytes20 hashedPubData = Utils.hashBytesToBytes20(_pubData);

        priorityRequests[nextPriorityRequestId] = PriorityTx({
        hashedPubData : hashedPubData,
        expirationBlock : expirationBlock,
        txType : _txType
        });

        emit NewPriorityRequest(msg.sender, nextPriorityRequestId, _txType, _pubData, uint256(expirationBlock));

        totalOpenPriorityRequests++;
    }

    /// @notice Register full exit request - pack pubdata, add priority request
    /// @param _accountName account name
    /// @param _asset Token address, 0 address for BNB
    function requestFullExit(string calldata _accountName, address _asset) public {
        delegateAdditional();
    }

    /// @notice Register full exit nft request - pack pubdata, add priority request
    /// @param _accountName account name
    /// @param _nftIndex account NFT index in zkbnb network
    function requestFullExitNft(string calldata _accountName, uint32 _nftIndex) public {
        delegateAdditional();
    }

    function setDefaultNFTFactory(NFTFactory _factory) external {
        delegateAdditional();
    }

    /// @notice Sends ETH
    /// @param _to Address of recipient
    /// @param _amount Amount of tokens to transfer
    /// @return bool flag indicating that transfer is successful
    function sendBNBNoRevert(address payable _to, uint256 _amount) internal returns (bool) {
        (bool callSuccess,) = _to.call{gas : WITHDRAWAL_GAS_LIMIT, value : _amount}("");
        return callSuccess;
    }

    function increaseBalanceToWithdraw(bytes22 _packedBalanceKey, uint128 _amount) internal {
        uint128 balance = pendingBalances[_packedBalanceKey].balanceToWithdraw;
        pendingBalances[_packedBalanceKey] = PendingBalance(balance.add(_amount), FILLED_GAS_RESERVE_VALUE);
    }

    /// @notice Reverts unverified blocks
    function revertBlocks(StoredBlockInfo[] memory _blocksToRevert) external {
        delegateAdditional();
    }

    /// @notice Delegates the call to the additional part of the main contract.
    /// @notice Should be only use to delegate the external calls as it passes the calldata
    /// @notice All functions delegated to additional contract should NOT be nonReentrant
    function delegateAdditional() internal {
        address _target = address(additionalZkBNB);
        assembly {
        // The pointer to the free memory slot
            let ptr := mload(0x40)
        // Copy function signature and arguments from calldata at zero position into memory at pointer position
            calldatacopy(ptr, 0x0, calldatasize())
        // Delegatecall method of the implementation contract, returns 0 on error
            let result := delegatecall(gas(), _target, ptr, calldatasize(), 0x0, 0)
        // Get the size of the last return data
            let size := returndatasize()
        // Copy the size length of bytes from return data at zero position to pointer position
            returndatacopy(ptr, 0x0, size)

        // Depending on result value
            switch result
            case 0 {
            // End execution and revert state changes
                revert(ptr, size)
            }
            default {
            // Return data with length of size at pointers position
                return (ptr, size)
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUInt128 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "12");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        return sub(a, b, "aa");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {
        require(b <= a, errorMessage);
        uint128 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint128 a, uint128 b) internal pure returns (uint128) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "13");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint128 a, uint128 b) internal pure returns (uint128) {
        return div(a, b, "ac");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint128 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint128 a, uint128 b) internal pure returns (uint128) {
        return mod(a, b, "ad");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUInt32 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, "12");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        return sub(a, b, "aa");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b <= a, errorMessage);
        uint32 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, "13");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        return div(a, b, "ac");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint32 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        return mod(a, b, "ad");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

import "./Upgradeable.sol";
import "./TxTypes.sol";

/// @title ZkBNB events
/// @author ZkBNB Team
interface Events {
    /// @notice Event emitted when a block is committed
    event BlockCommit(uint32 blockNumber);

    /// @notice Event emitted when a block is verified
    event BlockVerification(uint32 blockNumber);

    /// @notice Event emitted when user funds are withdrawn from the ZkBNB state and contract
    event Withdrawal(uint16 assetId, uint128 amount);

    /// @notice Event emitted when user funds are deposited to the zkbnb account
    event Deposit(uint16 assetId, bytes32 accountName, uint128 amount);

    /// @notice Event emitted when blocks are reverted
    event BlocksRevert(uint32 totalBlocksVerified, uint32 totalBlocksCommitted);

    /// @notice Exodus mode entered event
    event DesertMode();

    /// @notice New priority request event. Emitted when a request is placed into mapping
    event NewPriorityRequest(
        address sender,
        uint64 serialId,
        TxTypes.TxType txType,
        bytes pubData,
        uint256 expirationBlock
    );

    event RegisterZNS(
        string name,
        bytes32 nameHash,
        address owner,
        bytes32 zkbnbPubKeyX,
        bytes32 zkbnbPubKeyY,
        uint32 accountIndex
    );

    /// @notice Deposit committed event.
    event DepositCommit(
        uint32 indexed zkbnbBlockNumber,
        uint32 indexed accountIndex,
        bytes32 accountName,
        uint16 indexed assetId,
        uint128 amount
    );

    /// @notice Full exit committed event.
    event FullExitCommit(
        uint32 indexed zkbnbBlockId,
        uint32 indexed accountId,
        address owner,
        uint16 indexed tokenId,
        uint128 amount
    );

    /// @notice Notice period changed
    event NoticePeriodChange(uint256 newNoticePeriod);

    /// @notice NFT deposit event.
    event DepositNft(
        bytes32 accountNameHash,
        bytes32 nftContentHash,
        address tokenAddress,
        uint256 nftTokenId,
        uint16 creatorTreasuryRate
    );

    /// @notice NFT withdraw event.
    event WithdrawNft (
        uint32 accountIndex,
        address nftL1Address,
        address toAddress,
        uint256 nftL1TokenId
    );

    /// @notice Event emitted when user NFT is withdrawn from the zkSync state but not from contract
    event WithdrawalNFTPending(uint40 indexed nftIndex);

    /// @notice Default NFTFactory changed
    event NewDefaultNFTFactory(address indexed factory);

    /// @notice New NFT Factory
    event NewNFTFactory(bytes32 indexed _creatorAccountNameHash, uint32 _collectionId, address _factoryAddress);
}

/// @title Upgrade events
/// @author ZkBNB Team
interface UpgradeEvents {
    /// @notice Event emitted when new upgradeable contract is added to upgrade gatekeeper's list of managed contracts
    event NewUpgradable(uint256 indexed versionId, address indexed upgradeable);

    /// @notice Upgrade mode enter event
    event NoticePeriodStart(
        uint256 indexed versionId,
        address[] newTargets,
        uint256 noticePeriod // notice period (in seconds)
    );

    /// @notice Upgrade mode cancel event
    event UpgradeCancel(uint256 indexed versionId);

    /// @notice Upgrade mode preparation status event
    event PreparationStart(uint256 indexed versionId);

    /// @notice Upgrade mode complete event
    event UpgradeComplete(uint256 indexed versionId, address[] newTargets);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Bytes.sol";
import "./Storage.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

library Utils {
    /// @notice Returns lesser of two values
    function minU32(uint32 a, uint32 b) internal pure returns (uint32) {
        return a < b ? a : b;
    }

    /// @notice Returns lesser of two values
    function minU64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    /// @notice Returns lesser of two values
    function minU128(uint128 a, uint128 b) internal pure returns (uint128) {
        return a < b ? a : b;
    }

    /// @notice Sends tokens
    /// @dev NOTE: this function handles tokens that have transfer function not strictly compatible with ERC20 standard
    /// @dev NOTE: call `transfer` to this token may return (bool) or nothing
    /// @param _token Token address
    /// @param _to Address of recipient
    /// @param _amount Amount of tokens to transfer
    /// @return bool flag indicating that transfer is successful
    function sendERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        (bool callSuccess, bytes memory callReturnValueEncoded) = address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _amount)
        );
        // `transfer` method may return (bool) or nothing.
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    /// @notice Transfers token from one address to another
    /// @dev NOTE: this function handles tokens that have transfer function not strictly compatible with ERC20 standard
    /// @dev NOTE: call `transferFrom` to this token may return (bool) or nothing
    /// @param _token Token address
    /// @param _from Address of sender
    /// @param _to Address of recipient
    /// @param _amount Amount of tokens to transfer
    /// @return bool flag indicating that transfer is successful
    function transferFromERC20(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        (bool callSuccess, bytes memory callReturnValueEncoded) = address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _amount)
        );
        // `transferFrom` method may return (bool) or nothing.
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    function transferFromNFT(
        address _from,
        address _to,
        address _nftL1Address,
        uint256 _nftL1TokenId
    ) internal returns (bool success) {

        try IERC721(_nftL1Address).safeTransferFrom(
            _from,
            _to,
            _nftL1TokenId
        ) {
            success = true;
        } catch {
            success = false;
        }
        return success;
    }

    // TODO
    function transferFromERC721(
        address _from,
        address _to,
        address _tokenAddress,
        uint256 _nftTokenId
    ) internal returns (bool success) {
        try IERC721(_tokenAddress).safeTransferFrom(
            _from,
            _to,
            _nftTokenId
        ) {
            success = true;
        } catch {
            success = false;
        }
        return success;
    }

    /// @notice Recovers signer's address from ethereum signature for given message
    /// @param _signature 65 bytes concatenated. R (32) + S (32) + V (1)
    /// @param _messageHash signed message hash.
    /// @return address of the signer
    function recoverAddressFromEthSignature(bytes memory _signature, bytes32 _messageHash)
    internal
    pure
    returns (address)
    {
        require(_signature.length == 65, "P");
        // incorrect signature length

        bytes32 signR;
        bytes32 signS;
        uint8 signV;
        assembly {
            signR := mload(add(_signature, 32))
            signS := mload(add(_signature, 64))
            signV := byte(0, mload(add(_signature, 96)))
        }

        return ecrecover(_messageHash, signV, signR, signS);
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    /// @notice Returns new_hash = hash(old_hash + bytes)
    function concatHash(bytes32 _hash, bytes memory _bytes) internal pure returns (bytes32) {
        bytes32 result;
        assembly {
            let bytesLen := add(mload(_bytes), 32)
            mstore(_bytes, _hash)
            result := keccak256(_bytes, bytesLen)
        }
        return result;
    }

    function hashBytesToBytes20(bytes memory _bytes) internal pure returns (bytes20) {
        return bytes20(uint160(uint256(keccak256(_bytes))));
    }

    function bytesToUint256Arr(bytes memory _pubData) internal pure returns (uint256[] memory pubData){
        uint256 bytesCount = _pubData.length / 32;
        pubData = new uint[](bytesCount);
        uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        for (uint32 i = 0; i < bytesCount; ++i) {
            bytes32 result = Bytes.bytesToBytes32(Bytes.slice(_pubData, i * 32, 32), 0);
            pubData[i] = uint256(result) % q;
        }
        return pubData;
    }

}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

// Functions named bytesToX, except bytesToBytes20, where X is some type of size N < 32 (size of one word)
// implements the following algorithm:
// f(bytes memory input, uint offset) -> X out
// where byte representation of out is N bytes from input at the given offset
// 1) We compute memory location of the word W such that last N bytes of W is input[offset..offset+N]
// W_address = input + 32 (skip stored length of bytes) + offset - (32 - N) == input + offset + N
// 2) We load W from memory into out, last N bytes of W are placed into out

library Bytes {
    function toBytesFromUInt16(uint16 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 2);
    }

    function toBytesFromUInt24(uint24 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 3);
    }

    function toBytesFromUInt32(uint32 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 4);
    }

    function toBytesFromUInt128(uint128 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 16);
    }

    // Copies 'len' lower bytes from 'self' into a new 'bytes memory'.
    // Returns the newly created 'bytes memory'. The returned bytes will be of length 'len'.
    function toBytesFromUIntTruncated(uint256 self, uint8 byteLength) private pure returns (bytes memory bts) {
        require(byteLength <= 32, "Q");
        bts = new bytes(byteLength);
        // Even though the bytes will allocate a full word, we don't want
        // any potential garbage bytes in there.
        uint256 data = self << ((32 - byteLength) * 8);
        assembly {
            mstore(
            add(bts, 32), // BYTES_HEADER_SIZE
            data
            )
        }
    }

    // Copies 'self' into a new 'bytes memory'.
    // Returns the newly created 'bytes memory'. The returned bytes will be of length '20'.
    function toBytesFromAddress(address self) internal pure returns (bytes memory bts) {
        bts = toBytesFromUIntTruncated(uint256(self), 20);
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 20)
    function bytesToAddress(bytes memory self, uint256 _start) internal pure returns (address addr) {
        uint256 offset = _start + 20;
        require(self.length >= offset, "R");
        assembly {
            addr := mload(add(self, offset))
        }
    }

    // Reasoning about why this function works is similar to that of other similar functions, except NOTE below.
    // NOTE: that bytes1..32 is stored in the beginning of the word unlike other primitive types
    // NOTE: theoretically possible overflow of (_start + 20)
    function bytesToBytes20(bytes memory self, uint256 _start) internal pure returns (bytes20 r) {
        require(self.length >= (_start + 20), "S");
        assembly {
            r := mload(add(add(self, 0x20), _start))
        }
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 0x2)
    function bytesToUInt16(bytes memory _bytes, uint256 _start) internal pure returns (uint16 r) {
        uint256 offset = _start + 0x2;
        require(_bytes.length >= offset, "T");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 0x3)
    function bytesToUInt24(bytes memory _bytes, uint256 _start) internal pure returns (uint24 r) {
        uint256 offset = _start + 0x3;
        require(_bytes.length >= offset, "U");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x4)
    function bytesToUInt32(bytes memory _bytes, uint256 _start) internal pure returns (uint32 r) {
        uint256 offset = _start + 0x4;
        require(_bytes.length >= offset, "V");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x5)
    function bytesToUInt40(bytes memory _bytes, uint256 _start) internal pure returns (uint40 r) {
        uint256 offset = _start + 0x5;
        require(_bytes.length >= offset, "V");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x10)
    function bytesToUInt128(bytes memory _bytes, uint256 _start) internal pure returns (uint128 r) {
        uint256 offset = _start + 0x10;
        require(_bytes.length >= offset, "W");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 0x14)
    function bytesToUInt160(bytes memory _bytes, uint256 _start) internal pure returns (uint160 r) {
        uint256 offset = _start + 0x14;
        require(_bytes.length >= offset, "X");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x10)
    function bytesToUInt256(bytes memory _bytes, uint256 _start) internal pure returns (uint256 r) {
        uint256 offset = _start + 0x20;
        require(_bytes.length >= offset, "W");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x20)
    function bytesToBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32 r) {
        uint256 offset = _start + 0x20;
        require(_bytes.length >= offset, "Y");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // Original source code: https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol#L228
    // Get slice from bytes arrays
    // Returns the newly created 'bytes memory'
    // NOTE: theoretically possible overflow of (_start + _length)
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_bytes.length >= (_start + _length), "Z");
        // bytes length is less then start byte + length bytes

        bytes memory tempBytes = new bytes(_length);

        if (_length != 0) {
            assembly {
                let slice_curr := add(tempBytes, 0x20)
                let slice_end := add(slice_curr, _length)

                for {
                    let array_current := add(_bytes, add(_start, 0x20))
                } lt(slice_curr, slice_end) {
                    slice_curr := add(slice_curr, 0x20)
                    array_current := add(array_current, 0x20)
                } {
                    mstore(slice_curr, mload(array_current))
                }
            }
        }

        return tempBytes;
    }

    /// Reads byte stream
    /// @return newOffset - offset + amount of bytes read
    /// @return data - actually read data
    // NOTE: theoretically possible overflow of (_offset + _length)
    function read(
        bytes memory _data,
        uint256 _offset,
        uint256 _length
    ) internal pure returns (uint256 newOffset, bytes memory data) {
        data = slice(_data, _offset, _length);
        newOffset = _offset + _length;
    }

    // NOTE: theoretically possible overflow of (_offset + 1)
    function readBool(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bool r) {
        newOffset = _offset + 1;
        r = uint8(_data[_offset]) != 0;
    }

    // NOTE: theoretically possible overflow of (_offset + 1)
    function readUInt8(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint8 r) {
        newOffset = _offset + 1;
        r = uint8(_data[_offset]);
    }

    // NOTE: theoretically possible overflow of (_offset + 2)
    function readUInt16(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint16 r) {
        newOffset = _offset + 2;
        r = bytesToUInt16(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 3)
    function readUInt24(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint24 r) {
        newOffset = _offset + 3;
        r = bytesToUInt24(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 4)
    function readUInt32(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint32 r) {
        newOffset = _offset + 4;
        r = bytesToUInt32(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 5)
    function readUInt40(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint40 r) {
        newOffset = _offset + 5;
        r = bytesToUInt40(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 16)
    function readUInt128(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint128 r) {
        newOffset = _offset + 16;
        r = bytesToUInt128(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 16)
    function readUInt256(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint256 r) {
        newOffset = _offset + 32;
        r = bytesToUInt256(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 20)
    function readUInt160(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint160 r) {
        newOffset = _offset + 20;
        r = bytesToUInt160(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 20)
    function readAddress(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, address r) {
        newOffset = _offset + 20;
        r = bytesToAddress(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 20)
    function readBytes20(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bytes20 r) {
        newOffset = _offset + 20;
        r = bytesToBytes20(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 32)
    function readBytes32(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bytes32 r) {
        newOffset = _offset + 32;
        r = bytesToBytes32(_data, _offset);
    }

    /// Trim bytes into single word
    function trim(bytes memory _data, uint256 _newLength) internal pure returns (uint256 r) {
        require(_newLength <= 0x20, "10");
        // new_length is longer than word
        require(_data.length >= _newLength, "11");
        // data is to short

        uint256 a;
        assembly {
            a := mload(add(_data, 0x20)) // load bytes into uint256
        }

        return a >> ((0x20 - _newLength) * 8);
    }

    // Helper function for hex conversion.
    function halfByteToHex(bytes1 _byte) internal pure returns (bytes1 _hexByte) {
        require(uint8(_byte) < 0x10, "hbh11");
        // half byte's value is out of 0..15 range.

        // "FEDCBA9876543210" ASCII-encoded, shifted and automatically truncated.
        return bytes1(uint8(0x66656463626139383736353433323130 >> (uint8(_byte) * 8)));
    }

    // Convert bytes to ASCII hex representation
    function bytesToHexASCIIBytes(bytes memory _input) internal pure returns (bytes memory _output) {
        bytes memory outStringBytes = new bytes(_input.length * 2);

        // code in `assembly` construction is equivalent of the next code:
        // for (uint i = 0; i < _input.length; ++i) {
        //     outStringBytes[i*2] = halfByteToHex(_input[i] >> 4);
        //     outStringBytes[i*2+1] = halfByteToHex(_input[i] & 0x0f);
        // }
        assembly {
            let input_curr := add(_input, 0x20)
            let input_end := add(input_curr, mload(_input))

            for {
                let out_curr := add(outStringBytes, 0x20)
            } lt(input_curr, input_end) {
                input_curr := add(input_curr, 0x01)
                out_curr := add(out_curr, 0x02)
            } {
                let curr_input_byte := shr(0xf8, mload(input_curr))
            // here outStringByte from each half of input byte calculates by the next:
            //
            // "FEDCBA9876543210" ASCII-encoded, shifted and automatically truncated.
            // outStringByte = byte (uint8 (0x66656463626139383736353433323130 >> (uint8 (_byteHalf) * 8)))
                mstore(
                out_curr,
                shl(0xf8, shr(mul(shr(0x04, curr_input_byte), 0x08), 0x66656463626139383736353433323130))
                )
                mstore(
                add(out_curr, 0x01),
                shl(0xf8, shr(mul(and(0x0f, curr_input_byte), 0x08), 0x66656463626139383736353433323130))
                )
            }
        }
        return outStringBytes;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

pragma experimental ABIEncoderV2;

import "./Bytes.sol";
import "./Utils.sol";

/// @title zkbnb op tools
library TxTypes {

    /// @notice zkbnb circuit op type
    enum TxType {
        EmptyTx,
        RegisterZNS,
        Deposit,
        DepositNft,
        Transfer,
        Withdraw,
        CreateCollection,
        MintNft,
        TransferNft,
        AtomicMatch,
        CancelOffer,
        WithdrawNft,
        FullExit,
        FullExitNft
    }

    // Byte lengths
    uint8 internal constant CHUNK_SIZE = 32;
    // operation type bytes
    uint8 internal constant TX_TYPE_BYTES = 1;

    uint256 internal constant PACKED_TX_PUBDATA_BYTES = 6 * CHUNK_SIZE;

    struct RegisterZNS {
        uint8 txType;
        uint32 accountIndex;
        bytes32 accountName;
        bytes32 accountNameHash;
        bytes32 pubKeyX;
        bytes32 pubKeyY;
    }

    /// Serialize register zns pubdata
    function writeRegisterZNSPubDataForPriorityQueue(RegisterZNS memory _tx) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(TxType.RegisterZNS),
            _tx.accountIndex,
            _tx.accountName,
            _tx.accountNameHash, // account name hash
            _tx.pubKeyX,
            _tx.pubKeyY
        );
    }

    /// Deserialize register zns pubdata
    function readRegisterZNSPubData(bytes memory _data) internal pure returns (RegisterZNS memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = 27;
        // account index
        (offset, parsed.accountIndex) = Bytes.readUInt32(_data, offset);
        // tx byte
        offset += TX_TYPE_BYTES;

        // account name
        (offset, parsed.accountName) = Bytes.readBytes32(_data, offset);
        // account name hash
        (offset, parsed.accountNameHash) = Bytes.readBytes32(_data, offset);
        // public key
        (offset, parsed.pubKeyX) = Bytes.readBytes32(_data, offset);
        (offset, parsed.pubKeyY) = Bytes.readBytes32(_data, offset);

        offset += 32;

        require(offset == PACKED_TX_PUBDATA_BYTES, "N");
        return parsed;
    }

    /// @notice Write register zns pubdata for priority queue check.
    function checkRegisterZNSInPriorityQueue(RegisterZNS memory _tx, bytes20 hashedPubData) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeRegisterZNSPubDataForPriorityQueue(_tx)) == hashedPubData;
    }

    // Deposit pubdata
    struct Deposit {
        uint8 txType;
        uint32 accountIndex;
        bytes32 accountNameHash;
        uint16 assetId;
        uint128 amount;
    }

    //    uint256 internal constant PACKED_DEPOSIT_PUBDATA_BYTES = 2 * CHUNK_SIZE;

    /// Serialize deposit pubdata
    function writeDepositPubDataForPriorityQueue(Deposit memory _tx) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(TxType.Deposit),
            uint32(0),
            _tx.accountNameHash, // account name hash
            _tx.assetId, // asset id
            _tx.amount // state amount
        );
    }

    /// Deserialize deposit pubdata
    function readDepositPubData(bytes memory _data) internal pure returns (Deposit memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = 9;
        // account index
        (offset, parsed.accountIndex) = Bytes.readUInt32(_data, offset);
        // asset id
        (offset, parsed.assetId) = Bytes.readUInt16(_data, offset);
        // state amount
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset);
        // account name
        (offset, parsed.accountNameHash) = Bytes.readBytes32(_data, offset);

        offset += 129; // 128 + 1 tx type byte

        require(offset == PACKED_TX_PUBDATA_BYTES, "N");
        return parsed;
    }

    /// @notice Write deposit pubdata for priority queue check.
    function checkDepositInPriorityQueue(Deposit memory _tx, bytes20 hashedPubData) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeDepositPubDataForPriorityQueue(_tx)) == hashedPubData;
    }

    struct DepositNft {
        uint8 txType;
        uint32 accountIndex;
        uint40 nftIndex;
        address nftL1Address;
        uint32 creatorAccountIndex;
        uint16 creatorTreasuryRate;
        bytes32 nftContentHash;
        uint256 nftL1TokenId;
        bytes32 accountNameHash;
        uint16 collectionId;
    }

    //    uint256 internal constant PACKED_DEPOSIT_NFT_PUBDATA_BYTES = 5 * CHUNK_SIZE;

    /// Serialize deposit pubdata
    function writeDepositNftPubDataForPriorityQueue(DepositNft memory _tx) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(TxType.DepositNft),
            uint32(0),
            uint40(_tx.nftIndex),
            _tx.nftL1Address, // token address
            _tx.creatorAccountIndex,
            _tx.creatorTreasuryRate,
            _tx.nftContentHash,
            _tx.nftL1TokenId, // nft token id
            _tx.accountNameHash,
            _tx.collectionId// account name hash
        );
    }

    /// Deserialize deposit pubdata
    function readDepositNftPubData(bytes memory _data) internal pure returns (DepositNft memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = 2;
        // account index
        (offset, parsed.accountIndex) = Bytes.readUInt32(_data, offset);
        // nft index
        (offset, parsed.nftIndex) = Bytes.readUInt40(_data, offset);
        // nft l1 address
        (offset, parsed.nftL1Address) = Bytes.readAddress(_data, offset);
        // empty data + tx type byte
        offset += 25;
        // creator account index
        (offset, parsed.creatorAccountIndex) = Bytes.readUInt32(_data, offset);
        // creator treasury rate
        (offset, parsed.creatorTreasuryRate) = Bytes.readUInt16(_data, offset);
        // collection id
        (offset, parsed.collectionId) = Bytes.readUInt16(_data, offset);
        // nft content hash
        (offset, parsed.nftContentHash) = Bytes.readBytes32(_data, offset);
        // nft l1 token id
        (offset, parsed.nftL1TokenId) = Bytes.readUInt256(_data, offset);
        // account name
        (offset, parsed.accountNameHash) = Bytes.readBytes32(_data, offset);

        offset += 32;

        require(offset == PACKED_TX_PUBDATA_BYTES, "N");
        return parsed;
    }

    /// @notice Write deposit pubdata for priority queue check.
    function checkDepositNftInPriorityQueue(DepositNft memory _tx, bytes20 hashedPubData) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeDepositNftPubDataForPriorityQueue(_tx)) == hashedPubData;
    }

    // Withdraw pubdata
    struct Withdraw {
        uint8 txType;
        uint32 accountIndex;
        address toAddress;
        uint16 assetId;
        uint128 assetAmount;
        uint32 gasFeeAccountIndex;
        uint16 gasFeeAssetId;
        uint16 gasFeeAssetAmount;
    }

    //    uint256 internal constant PACKED_WITHDRAW_PUBDATA_BYTES = 2 * CHUNK_SIZE;

    /// Deserialize withdraw pubdata
    function readWithdrawPubData(bytes memory _data) internal pure returns (Withdraw memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = 5;
        // account index
        (offset, parsed.accountIndex) = Bytes.readUInt32(_data, offset);
        // address
        (offset, parsed.toAddress) = Bytes.readAddress(_data, offset);
        // asset id
        (offset, parsed.assetId) = Bytes.readUInt16(_data, offset);
        // empty data + tx type byte
        offset += 9;
        // amount
        (offset, parsed.assetAmount) = Bytes.readUInt128(_data, offset);
        // gas fee account index
        (offset, parsed.gasFeeAccountIndex) = Bytes.readUInt32(_data, offset);
        // gas fee asset id
        (offset, parsed.gasFeeAssetId) = Bytes.readUInt16(_data, offset);
        // gas fee asset amount
        (offset, parsed.gasFeeAssetAmount) = Bytes.readUInt16(_data, offset);
        offset += 128;

        require(offset == PACKED_TX_PUBDATA_BYTES, "N");
        return parsed;
    }

    // Withdraw Nft pubdata
    struct WithdrawNft {
        uint8 txType;
        uint32 fromAccountIndex;
        uint32 creatorAccountIndex;
        uint16 creatorTreasuryRate;
        uint40 nftIndex;
        address nftL1Address;
        address toAddress;
        uint32 gasFeeAccountIndex;
        uint16 gasFeeAssetId;
        uint16 gasFeeAssetAmount;
        bytes32 nftContentHash;
        uint256 nftL1TokenId;
        bytes32 creatorAccountNameHash;
        uint32 collectionId;
    }

    //    uint256 internal constant PACKED_WITHDRAWNFT_PUBDATA_BYTES = 6 * CHUNK_SIZE;

    /// Deserialize withdraw pubdata
    function readWithdrawNftPubData(bytes memory _data) internal pure returns (WithdrawNft memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = 14;
        // account index
        (offset, parsed.fromAccountIndex) = Bytes.readUInt32(_data, offset);
        // creator account index
        (offset, parsed.creatorAccountIndex) = Bytes.readUInt32(_data, offset);
        // creator treasury rate
        (offset, parsed.creatorTreasuryRate) = Bytes.readUInt16(_data, offset);
        // nft index
        (offset, parsed.nftIndex) = Bytes.readUInt40(_data, offset);
        // collection id
        (offset, parsed.collectionId) = Bytes.readUInt16(_data, offset);
        // empty data + tx type byte
        offset += 13;
        // nft l1 address
        (offset, parsed.nftL1Address) = Bytes.readAddress(_data, offset);
        // empty data
        offset += 4;
        // nft l1 address
        (offset, parsed.toAddress) = Bytes.readAddress(_data, offset);
        // gas fee account index
        (offset, parsed.gasFeeAccountIndex) = Bytes.readUInt32(_data, offset);
        // gas fee asset id
        (offset, parsed.gasFeeAssetId) = Bytes.readUInt16(_data, offset);
        // gas fee asset amount
        (offset, parsed.gasFeeAssetAmount) = Bytes.readUInt16(_data, offset);
        // nft content hash
        (offset, parsed.nftContentHash) = Bytes.readBytes32(_data, offset);
        // nft token id
        (offset, parsed.nftL1TokenId) = Bytes.readUInt256(_data, offset);
        // account name hash
        (offset, parsed.creatorAccountNameHash) = Bytes.readBytes32(_data, offset);

        require(offset == PACKED_TX_PUBDATA_BYTES, "N");
        return parsed;
    }

    // full exit pubdata
    struct FullExit {
        uint8 txType;
        uint32 accountIndex;
        uint16 assetId;
        uint128 assetAmount;
        bytes32 accountNameHash;
    }

    //    uint256 internal constant PACKED_FULLEXIT_PUBDATA_BYTES = 2 * CHUNK_SIZE;

    /// Serialize full exit pubdata
    function writeFullExitPubDataForPriorityQueue(FullExit memory _tx) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(TxType.FullExit),
            uint32(0),
            _tx.assetId, // asset id
            uint128(0), // asset amount
            _tx.accountNameHash // account name
        );
    }

    /// Deserialize full exit pubdata
    function readFullExitPubData(bytes memory _data) internal pure returns (FullExit memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = 9;
        // account index
        (offset, parsed.accountIndex) = Bytes.readUInt32(_data, offset);
        // asset id
        (offset, parsed.assetId) = Bytes.readUInt16(_data, offset);
        // asset state amount
        (offset, parsed.assetAmount) = Bytes.readUInt128(_data, offset);
        // account name
        (offset, parsed.accountNameHash) = Bytes.readBytes32(_data, offset);

        // empty data + tx type byte
        offset += 129;

        require(offset == PACKED_TX_PUBDATA_BYTES, "N");
        return parsed;
    }

    /// @notice Write full exit pubdata for priority queue check.
    function checkFullExitInPriorityQueue(FullExit memory _tx, bytes20 hashedPubData) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeFullExitPubDataForPriorityQueue(_tx)) == hashedPubData;
    }

    // full exit nft pubdata
    struct FullExitNft {
        uint8 txType;
        uint32 accountIndex;
        uint32 creatorAccountIndex;
        uint16 creatorTreasuryRate;
        uint40 nftIndex;
        uint16 collectionId;
        address nftL1Address;
        bytes32 accountNameHash;
        bytes32 creatorAccountNameHash;
        bytes32 nftContentHash;
        uint256 nftL1TokenId;
    }

    //    uint256 internal constant PACKED_FULLEXITNFT_PUBDATA_BYTES = 6 * CHUNK_SIZE;

    /// Serialize full exit nft pubdata
    function writeFullExitNftPubDataForPriorityQueue(FullExitNft memory _tx) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(TxType.FullExitNft),
            uint32(0),
            uint32(0),
            uint16(0),
            _tx.nftIndex,
            uint16(0), // collection id
            address(0x0), // nft l1 address
            _tx.accountNameHash, // account name hash
            bytes32(0), // creator account name hash
            bytes32(0), // nft content hash
            uint256(0) // token id
        );
    }

    /// Deserialize full exit nft pubdata
    function readFullExitNftPubData(bytes memory _data) internal pure returns (FullExitNft memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = 14;
        // account index
        (offset, parsed.accountIndex) = Bytes.readUInt32(_data, offset);
        // creator account index
        (offset, parsed.creatorAccountIndex) = Bytes.readUInt32(_data, offset);
        // creator treasury rate
        (offset, parsed.creatorTreasuryRate) = Bytes.readUInt16(_data, offset);
        // nft index
        (offset, parsed.nftIndex) = Bytes.readUInt40(_data, offset);
        // collection id
        (offset, parsed.collectionId) = Bytes.readUInt16(_data, offset);
        // empty data + tx type byte
        offset += 13;
        // nft l1 address
        (offset, parsed.nftL1Address) = Bytes.readAddress(_data, offset);
        // account name hash
        (offset, parsed.accountNameHash) = Bytes.readBytes32(_data, offset);
        // creator account name hash
        (offset, parsed.creatorAccountNameHash) = Bytes.readBytes32(_data, offset);
        // nft content hash
        (offset, parsed.nftContentHash) = Bytes.readBytes32(_data, offset);
        // nft l1 token id
        (offset, parsed.nftL1TokenId) = Bytes.readUInt256(_data, offset);

        require(offset == PACKED_TX_PUBDATA_BYTES, "N");
        return parsed;
    }

    /// @notice Write full exit nft pubdata for priority queue check.
    function checkFullExitNftInPriorityQueue(FullExitNft memory _tx, bytes20 hashedPubData) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeFullExitNftPubDataForPriorityQueue(_tx)) == hashedPubData;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;


interface NFTFactory {
    function mintFromZkBNB(
        address _creatorAddress,
        address _toAddress,
        uint256 _nftTokenId,
        bytes32 _nftContentHash,
        bytes memory _extraData
    )
    external;

    event MintNFTFromZkBNB(
        address indexed _creatorAddress,
        address indexed _toAddress,
        uint256 _nftTokenId,
        bytes32 _nftContentHash,
        bytes _extraData
    );
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

/// @title ZkBNB configuration constants
/// @author ZkBNB Team
contract Config {

    /// @dev Configurable notice period
    uint256 public constant UPGRADE_NOTICE_PERIOD = 4 weeks;
    /// @dev Shortest notice period
    uint256 public constant SHORTEST_UPGRADE_NOTICE_PERIOD = 0;

    uint256 public constant SECURITY_COUNCIL_MEMBERS_NUMBER = 3;

    /// @dev ERC20 tokens and ETH withdrawals gas limit, used only for complete withdrawals
    uint256 public constant WITHDRAWAL_GAS_LIMIT = 100000;
    /// @dev NFT withdrawals gas limit, used only for complete withdrawals
    uint256 internal constant WITHDRAWAL_NFT_GAS_LIMIT = 300000;
    /// @dev Max amount of tokens registered in the network (excluding ETH, which is hardcoded as tokenId = 0)
    uint16 public constant MAX_AMOUNT_OF_REGISTERED_ASSETS = 2 ** 16 - 2;

    /// @dev Max account id that could be registered in the network
    uint32 public constant MAX_ACCOUNT_INDEX = 2 ** 32 - 2;

    /// @dev Max deposit of ERC20 token that is possible to deposit
    uint128 public constant MAX_DEPOSIT_AMOUNT = 2 ** 104 - 1;

    /// @dev Expiration delta for priority request to be satisfied (in seconds)
    /// @dev NOTE: Priority expiration should be > (EXPECT_VERIFICATION_IN * BLOCK_PERIOD)
    /// @dev otherwise incorrect block with priority op could not be reverted.
    uint256 internal constant PRIORITY_EXPIRATION_PERIOD = 7 days;

    /// @dev Expected average period of block creation
    uint256 internal constant BLOCK_PERIOD = 3 seconds;

    /// @dev Expiration delta for priority request to be satisfied (in seconds)
    /// @dev NOTE: Priority expiration should be > (EXPECT_VERIFICATION_IN * BLOCK_PERIOD)
    /// @dev otherwise incorrect block with priority op could not be reverted.
    uint256 internal constant PRIORITY_EXPIRATION = PRIORITY_EXPIRATION_PERIOD / BLOCK_PERIOD;

    uint32 public constant SPECIAL_ACCOUNT_ID = 0;
    address public constant SPECIAL_ACCOUNT_ADDRESS = address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);

    uint32 public constant MAX_FUNGIBLE_ASSET_ID = (2 ** 32) - 2;

    uint256 public constant TX_SIZE = 6 * 32;

    uint40 public constant MAX_NFT_INDEX = (2 ** 40) - 2;

}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./IBaseRegistrar.sol";
import "./IPriceOracle.sol";
import "./ZNS.sol";
import "./utils/Names.sol";

/**
 * ZNSController is a registrar allocating subdomain names to users in ZkBNB in a FIFS way.
 */
contract ZNSController is IBaseRegistrar, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using Names for string;

    // ZNS registry
    ZNS public zns;
    // Price Oracle
    IPriceOracle public prices;

    event Withdraw(address _to, uint256 _value);

    // The nodehash/namehash of the root node this registrar owns (eg, .legend)
    bytes32 public baseNode;
    // A map of addresses that are authorized to controll the registrar(eg, register names)
    mapping(address => bool) public controllers;
    // A map to record the L2 owner of each node. A L2 owner can own only 1 name.
    // pubKey => nodeHash
    mapping(bytes32 => bytes32) ZNSPubKeyMapper;

    modifier onlyController {
        require(controllers[msg.sender]);
        _;
    }

    modifier live {
        require(zns.owner(baseNode) == address(this));
        _;
    }

    function initialize(bytes calldata initializationParameters) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        (address _znsAddr, address _prices, bytes32 _node) = abi.decode(initializationParameters, (address, address, bytes32));
        zns = ZNS(_znsAddr);
        prices = IPriceOracle(_prices);
        uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        baseNode = bytes32(uint256(_node)%q);

        // initialize ownership
        controllers[msg.sender] = true;
    }

    // Authorizes a controller, who can control this registrar.
    function addController(address _controller) external override onlyOwner {
        controllers[_controller] = true;
        emit ControllerAdded(_controller);
    }

    // Revoke controller permission for an address.
    function removeController(address _controller) external override onlyOwner {
        controllers[_controller] = false;
        emit ControllerRemoved(_controller);
    }

    // Set resolver for the node this registrar manages.
    // This msg.sender must be the owner of base node.
    function setThisResolver(address _resolver) external override onlyOwner {
        zns.setResolver(baseNode, _resolver);
    }

    function getOwner(bytes32 node) external view returns (address){
        return zns.owner(node);
    }

    /**
     * @dev Register a new node under base node if it not exists.
     * @param _name The plaintext of the name to register
     * @param _owner The address to receive this name
     * @param _pubKeyX The pub key x of the owner
     * @param _pubKeyY The pub key y of the owner
     */
    function registerZNS(string calldata _name, address _owner, bytes32 _pubKeyX, bytes32 _pubKeyY, address _resolver) external override onlyController payable returns (bytes32 subnode, uint32 accountIndex){
        // Check if this name is valid
        require(_valid(_name), "invalid name");
        // This L2 owner should not own any name before
        require(_validPubKey(_pubKeyY), "pub key existed");
        // Calculate price using PriceOracle
        uint256 price = prices.price(_name);
        // Check enough value
        require(
            msg.value >= price,
            "nev"
        );

        // Get the name hash
        bytes32 label = keccak256Hash(bytes(_name));
        // This subnode should not be registered before
        require(!zns.subNodeRecordExists(baseNode, label), "subnode existed");
        // Register subnode
        subnode = zns.setSubnodeRecord(baseNode, label, _owner, _pubKeyX, _pubKeyY, _resolver);
        accountIndex = zns.setSubnodeAccountIndex(subnode);

        // Update L2 owner mapper
        ZNSPubKeyMapper[_pubKeyY] = subnode;

        emit ZNSRegistered(_name, subnode, _owner, _pubKeyX, _pubKeyY, price);

        // Refund remained value to the owner of this name
        if (msg.value > price) {
            payable(_owner).transfer(
                msg.value - price
            );
        }

        return (subnode, accountIndex);
    }

    /**
     * @dev Withdraw BNB from this contract, only called by the owner of this contract.
     * @param _to The address to receive
     * @param _value The BNB amount to withdraw
     */
    function withdraw(address _to, uint256 _value) external onlyOwner {
        // Check not too much value
        require(_value < address(this).balance, "tmv");
        // Withdraw
        payable(_to).transfer(_value);

        emit Withdraw(_to, _value);
    }

    function getSubnodeNameHash(string memory name) external view returns (bytes32) {
        uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        bytes32 subnode = keccak256Hash(abi.encodePacked(baseNode, keccak256Hash(bytes(name))));
        subnode = bytes32(uint256(subnode) % q);
        return subnode;
    }

    function isRegisteredNameHash(bytes32 _nameHash) external view returns (bool){
        return zns.recordExists(_nameHash);
    }

    function isRegisteredZNSName(string memory _name) external view returns (bool) {
        bytes32 subnode = this.getSubnodeNameHash(_name);
        return this.isRegisteredNameHash(subnode);
    }

    function getZNSNamePrice(string calldata name) external view returns (uint256) {
        return prices.price(name);
    }

    function _valid(string memory _name) internal pure returns (bool) {
        return _validCharset(_name) && _validLength(_name);
    }

    function _validCharset(string memory _name) internal pure returns (bool) {
        return _name.charsetValid();
    }

    function _validLength(string memory _name) internal pure returns (bool) {
        return _name.strlen() >= 3 && _name.strlen() <= 32;
    }

    function _validPubKey(bytes32 _pubKey) internal view returns (bool) {
        return ZNSPubKeyMapper[_pubKey] == 0x0;
    }

    function keccak256Hash(bytes memory input) public view returns (bytes32 result) {
        result = keccak256(input);
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

import "./ZkBNBOwnable.sol";
import "./Upgradeable.sol";
import "./UpgradeableMaster.sol";

/// @title Proxy Contract
/// @dev NOTICE: Proxy must implement UpgradeableMaster interface to prevent calling some function of it not by master of proxy
/// @author ZkBNB Team
contract Proxy is Upgradeable, UpgradeableMaster, ZkBNBOwnable {
    /// @dev Storage position of "target" (actual implementation address: keccak256('eip1967.proxy.implementation') - 1)
    bytes32 private constant TARGET_POSITION = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice Contract constructor
    /// @dev Calls Ownable contract constructor and initialize target
    /// @param target Initial implementation address
    /// @param targetInitializationParameters Target initialization parameters
    constructor(address target, bytes memory targetInitializationParameters) ZkBNBOwnable(msg.sender) {
        setTarget(target);
        (bool initializationSuccess,) = getTarget().delegatecall(
            abi.encodeWithSignature("initialize(bytes)", targetInitializationParameters)
        );
        require(initializationSuccess, "uin11");
        // uin11 - target initialization failed
    }

    /// @notice Intercepts initialization calls
    function initialize(bytes calldata) external pure {
        revert("ini11");
        // ini11 - interception of initialization call
    }

    /// @notice Intercepts upgrade calls
    function upgrade(bytes calldata) external pure {
        revert("upg11");
        // upg11 - interception of upgrade call
    }

    /// @notice Returns target of contract
    /// @return target Actual implementation address
    function getTarget() public view returns (address target) {
        bytes32 position = TARGET_POSITION;
        assembly {
            target := sload(position)
        }
    }

    /// @notice Sets new target of contract
    /// @param _newTarget New actual implementation address
    function setTarget(address _newTarget) internal {
        bytes32 position = TARGET_POSITION;
        assembly {
            sstore(position, _newTarget)
        }
    }

    /// @notice Upgrades target
    /// @param newTarget New target
    /// @param newTargetUpgradeParameters New target upgrade parameters
    function upgradeTarget(address newTarget, bytes calldata newTargetUpgradeParameters) external override {
        requireMaster(msg.sender);

        setTarget(newTarget);
        (bool upgradeSuccess,) = getTarget().delegatecall(
            abi.encodeWithSignature("upgrade(bytes)", newTargetUpgradeParameters)
        );
        require(upgradeSuccess, "ufu11");
        // ufu11 - target upgrade failed
    }

    /// @notice Performs a delegatecall to the contract implementation
    /// @dev Fallback function allowing to perform a delegatecall to the given implementation
    /// This function will return whatever the implementation call returns
    function _fallback() internal {
        address _target = getTarget();
        assembly {
        // The pointer to the free memory slot
            let ptr := mload(0x40)
        // Copy function signature and arguments from calldata at zero position into memory at pointer position
            calldatacopy(ptr, 0x0, calldatasize())
        // Delegatecall method of the implementation contract, returns 0 on error
            let result := delegatecall(gas(), _target, ptr, calldatasize(), 0x0, 0)
        // Get the size of the last return data
            let size := returndatasize()
        // Copy the size length of bytes from return data at zero position to pointer position
            returndatacopy(ptr, 0x0, size)
        // Depending on result value
            switch result
            case 0 {
            // End execution and revert state changes
                revert(ptr, size)
            }
            default {
            // Return data with length of size at pointers position
                return (ptr, size)
            }
        }
    }

    /// @notice Will run when no functions matches call data
    fallback() external payable {
        _fallback();
    }

    /// @notice Same as fallback but called when calldata is empty
    receive() external payable {
        _fallback();
    }

    /// UpgradeableMaster functions

    /// @notice Notice period before activation preparation status of upgrade mode
    function getNoticePeriod() external override returns (uint256) {
        (bool success, bytes memory result) = getTarget().delegatecall(abi.encodeWithSignature("getNoticePeriod()"));
        require(success, "unp11");
        // unp11 - upgradeNoticePeriod delegatecall failed
        return abi.decode(result, (uint256));
    }

    /// @notice Notifies proxy contract that notice period started
    function upgradeNoticePeriodStarted() external override {
        requireMaster(msg.sender);
        (bool success,) = getTarget().delegatecall(abi.encodeWithSignature("upgradeNoticePeriodStarted()"));
        require(success, "nps11");
        // nps11 - upgradeNoticePeriodStarted delegatecall failed
    }

    /// @notice Notifies proxy contract that upgrade preparation status is activated
    function upgradePreparationStarted() external override {
        requireMaster(msg.sender);
        (bool success,) = getTarget().delegatecall(abi.encodeWithSignature("upgradePreparationStarted()"));
        require(success, "ups11");
        // ups11 - upgradePreparationStarted delegatecall failed
    }

    /// @notice Notifies proxy contract that upgrade canceled
    function upgradeCanceled() external override {
        requireMaster(msg.sender);
        (bool success,) = getTarget().delegatecall(abi.encodeWithSignature("upgradeCanceled()"));
        require(success, "puc11");
        // puc11 - upgradeCanceled delegatecall failed
    }

    /// @notice Notifies proxy contract that upgrade finishes
    function upgradeFinishes() external override {
        requireMaster(msg.sender);
        (bool success,) = getTarget().delegatecall(abi.encodeWithSignature("upgradeFinishes()"));
        require(success, "puf11");
        // puf11 - upgradeFinishes delegatecall failed
    }

    /// @notice Checks that contract is ready for upgrade
    /// @return bool flag indicating that contract is ready for upgrade
    function isReadyForUpgrade() external override returns (bool) {
        (bool success, bytes memory result) = getTarget().delegatecall(abi.encodeWithSignature("isReadyForUpgrade()"));
        require(success, "rfu11");
        // rfu11 - readyForUpgrade delegatecall failed
        return abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

/// @title Interface of the upgradeable master contract (defines notice period duration and allows finish upgrade during preparation of it)
/// @author ZkBNB Team
interface UpgradeableMaster {
    /// @notice Notice period before activation preparation status of upgrade mode
    function getNoticePeriod() external returns (uint256);

    /// @notice Notifies contract that notice period started
    function upgradeNoticePeriodStarted() external;

    /// @notice Notifies contract that upgrade preparation status is activated
    function upgradePreparationStarted() external;

    /// @notice Notifies contract that upgrade canceled
    function upgradeCanceled() external;

    /// @notice Notifies contract that upgrade finishes
    function upgradeFinishes() external;

    /// @notice Checks that contract is ready for upgrade
    /// @return bool flag indicating that contract is ready for upgrade
    function isReadyForUpgrade() external returns (bool);
}

// SPDX-License-Identifier: MIT OR Apache-2.0
// solhint-disable max-states-count

pragma solidity ^0.7.6;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Config.sol";
import "./Governance.sol";
import "./ZkBNBVerifier.sol";
import "./TxTypes.sol";
import "./AdditionalZkBNB.sol";
import "./ZNSController.sol";
import "./resolvers/PublicResolver.sol";
import "./NFTFactory.sol";

/// @title zkbnb storage contract
/// @author ZkBNB Labs
contract Storage {

    /// @dev Flag indicates that upgrade preparation status is active
    /// @dev Will store false in case of not active upgrade mode
    bool internal upgradePreparationActive;

    /// @dev Upgrade preparation activation timestamp (as seconds since unix epoch)
    /// @dev Will be equal to zero in case of not active upgrade mode
    uint256 internal upgradePreparationActivationTime;

    /// @dev Upgrade notice period, possibly shorten by the security council
    uint256 internal approvedUpgradeNoticePeriod;

    /// @dev Upgrade start timestamp (as seconds since unix epoch)
    /// @dev Will be equal to zero in case of not active upgrade mode
    uint256 internal upgradeStartTimestamp;

    /// @dev Stores boolean flags which means the confirmations of the upgrade for each member of security council
    /// @dev Will store zeroes in case of not active upgrade mode
    mapping(uint256 => bool) internal securityCouncilApproves;
    uint256 internal numberOfApprovalsFromSecurityCouncil;

    // account root
    bytes32 public stateRoot;

    /// @notice Priority Operation container
    /// @member hashedPubData Hashed priority operation public data
    /// @member expirationBlock Expiration block number (ETH block) for this request (must be satisfied before)
    /// @member opType Priority operation type
    struct PriorityTx {
        bytes20 hashedPubData;
        uint64 expirationBlock;
        TxTypes.TxType txType;
    }

    /// @dev Priority Requests mapping (request id - operation)
    /// @dev Contains op type, pubdata and expiration block of unsatisfied requests.
    /// @dev Numbers are in order of requests receiving
    mapping(uint64 => PriorityTx) internal priorityRequests;

    /// @dev Verifier contract. Used to verify block proof and exit proof
    ZkBNBVerifier internal verifier;

    /// @dev Governance contract. Contains the governor (the owner) of whole system, validators list, possible tokens list
    Governance internal governance;

    ZNSController internal znsController;
    PublicResolver internal znsResolver;

    uint8 internal constant FILLED_GAS_RESERVE_VALUE = 0xff; // we use it to set gas revert value so slot will not be emptied with 0 balance
    struct PendingBalance {
        uint128 balanceToWithdraw;
        uint8 gasReserveValue; // gives user opportunity to fill storage slot with nonzero value
    }

    /// @dev Root-chain balances (per owner and token id, see packAddressAndAssetId) to withdraw
    mapping(bytes22 => PendingBalance) internal pendingBalances;

    AdditionalZkBNB internal additionalZkBNB;

    /// @notice Total number of committed blocks i.e. blocks[totalBlocksCommitted] points at the latest committed block
    uint32 public totalBlocksCommitted;
    // total blocks that have been verified
    uint32 public totalBlocksVerified;

    /// @dev First open priority request id
    uint64 public firstPriorityRequestId;

    /// @dev Total number of requests
    uint64 public totalOpenPriorityRequests;

    /// @dev Total number of committed requests.
    /// @dev Used in checks: if the request matches the operation on Rollup contract and if provided number of requests is not too big
    uint64 internal totalCommittedPriorityRequests;

    /// @notice Packs address and token id into single word to use as a key in balances mapping
    function packAddressAndAssetId(address _address, uint16 _assetId) internal pure returns (bytes22) {
        return bytes22((uint176(_address) | (uint176(_assetId) << 160)));
    }

    struct StoredBlockInfo {
        uint16 blockSize;
        uint32 blockNumber;
        uint64 priorityOperations;
        bytes32 pendingOnchainOperationsHash;
        uint256 timestamp;
        bytes32 stateRoot;
        bytes32 commitment;
    }

    function hashStoredBlockInfo(StoredBlockInfo memory _block) internal pure returns (bytes32) {
        return keccak256(abi.encode(_block));
    }

    /// @dev Stored hashed StoredBlockInfo for some block number
    mapping(uint32 => bytes32) public storedBlockHashes;

    /// @dev Flag indicates that exodus (mass exit) mode is triggered
    /// @dev Once it was raised, it can not be cleared again, and all users must exit
    bool public desertMode;

    /// @dev Flag indicates that a user has exited in the exodus mode certain token balance (per account id and tokenId)
    mapping(uint32 => mapping(uint32 => bool)) internal performedDesert;

    /// @notice Checks that current state not is exodus mode
    function requireActive() internal view {
        require(!desertMode, "L");
        // desert mode activated
    }

    mapping(uint40 => TxTypes.WithdrawNft) internal pendingWithdrawnNFTs;

    struct L2NftInfo {
        uint40 nftIndex;
        uint32 creatorAccountIndex;
        uint16 creatorTreasuryRate;
        bytes32 nftContentHash;
        uint16 collectionId;
    }

    mapping(bytes32 => L2NftInfo) internal l2Nfts;

    /// @notice NFTFactories registered.
    /// @dev creator accountNameHash => CollectionId => NFTFactory
    mapping(bytes32 => mapping(uint32 => address)) public nftFactories;

    /// @notice Address which will be used if no factories is specified.
    address public defaultNFTFactory;

}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.7.6;

/// @title Interface of the upgradeable contract
/// @author ZkBNB Team
interface Upgradeable {
    /// @notice Upgrades target of upgradeable contract
    /// @param newTarget New target
    /// @param newTargetInitializationParameters New target initialization parameters
    function upgradeTarget(address newTarget, bytes calldata newTargetInitializationParameters) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

import "./Config.sol";
import "./Utils.sol";
import "./AssetGovernance.sol";
import "./SafeMathUInt32.sol";

/// @title Governance Contract
/// @author ZkBNB Team
contract Governance is Config {

    /// @notice Token added to Franklin net
    event NewAsset(address assetAddress, uint16 assetId);

    /// @notice Governor changed
    event NewGovernor(address newGovernor);

    /// @notice Token Governance changed
    event NewAssetGovernance(AssetGovernance newAssetGovernance);

    event ValidatorStatusUpdate(address validatorAddress, bool isActive);

    event AssetPausedUpdate(address token, bool paused);

    /// @notice Address which will exercise governance over the network i.e. add tokens, change validator set, conduct upgrades
    address public networkGovernor;

    /// @notice Total number of ERC20 tokens registered in the network (excluding ETH, which is hardcoded as assetId = 0)
    uint16 public totalAssets;

    mapping(address => bool) public validators;

    /// @notice Paused tokens list, deposits are impossible to create for paused tokens
    mapping(uint16 => bool) public pausedAssets;

    mapping(address => uint16) public assetsList;
    mapping(uint16 => address) public assetAddresses;
    mapping(address => bool) public isAddressExists;

    /// @notice Address that is authorized to add tokens to the Governance.
    AssetGovernance public assetGovernance;

    /// @notice Governance contract initialization. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param initializationParameters Encoded representation of initialization parameters:
    ///     _networkGovernor The address of network governor
    function initialize(bytes calldata initializationParameters) external {
        address _networkGovernor = abi.decode(initializationParameters, (address));

        networkGovernor = _networkGovernor;
    }

    /// @notice Governance contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    // solhint-disable-next-line no-empty-blocks
    function upgrade(bytes calldata upgradeParameters) external {}

    /// @notice Change current governor
    /// @param _newGovernor Address of the new governor
    function changeGovernor(address _newGovernor) external {
        requireGovernor(msg.sender);
        if (networkGovernor != _newGovernor) {
            networkGovernor = _newGovernor;
            emit NewGovernor(_newGovernor);
        }
    }

    function changeAssetGovernance(AssetGovernance _newAssetGovernance) external {
        requireGovernor(msg.sender);
        if (assetGovernance != _newAssetGovernance) {
            assetGovernance = _newAssetGovernance;
            emit NewAssetGovernance(_newAssetGovernance);
        }
    }

    /// @notice Add asset to the list of networks tokens
    /// @param _asset Token address
    function addAsset(address _asset) external {
        require(msg.sender == address(assetGovernance), "1E");
        require(assetsList[_asset] == 0, "1e");
        // token exists
        require(totalAssets < MAX_AMOUNT_OF_REGISTERED_ASSETS, "1f");
        // no free identifiers for tokens

        totalAssets++;
        uint16 newAssetId = totalAssets;
        // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

        assetAddresses[newAssetId] = _asset;
        assetsList[_asset] = newAssetId;
        emit NewAsset(_asset, newAssetId);
    }

    function setAssetPaused(address _assetAddress, bool _assetPaused) external {
        requireGovernor(msg.sender);

        uint16 assetId = this.validateAssetAddress(_assetAddress);
        if (pausedAssets[assetId] != _assetPaused) {
            pausedAssets[assetId] = _assetPaused;
            emit AssetPausedUpdate(_assetAddress, _assetPaused);
        }
    }

    function setValidator(address _validator, bool _active) external {
        requireGovernor(msg.sender);
        if (validators[_validator] != _active) {
            validators[_validator] = _active;
            emit ValidatorStatusUpdate(_validator, _active);
        }
    }

    /// @notice Check if specified address is governor
    /// @param _address Address to check
    function requireGovernor(address _address) public view {
        require(_address == networkGovernor, "1g");
        // only by governor
    }

    function requireActiveValidator(address _address) external view {
        require(validators[_address], "invalid validator");
    }

    function validateAssetAddress(address _assetAddr) external view returns (uint16) {
        uint16 assetId = assetsList[_assetAddr];
        require(assetId != 0, "1i");
        require(!pausedAssets[assetId], "2i");
        return assetId;
    }
}

// SPDX-License-Identifier: AML

pragma solidity ^0.7.6;

contract ZkBNBVerifier {

    function initialize(bytes calldata) external {}

    /// @notice Verifier contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    function upgrade(bytes calldata upgradeParameters) external {}

    function ScalarField()
    public pure returns (uint256)
    {
        return 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }

    function NegateY(uint256 Y)
    internal pure returns (uint256)
    {
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        return q - (Y % q);
    }

    function accumulate(
        uint256[] memory in_proof,
        uint256[] memory proof_inputs, // public inputs, length is num_inputs * num_proofs
        uint256 num_proofs
    ) internal view returns (
        uint256[] memory proofsAandC,
        uint256[] memory inputAccumulators
    ) {
        uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        uint256 numPublicInputs = proof_inputs.length / num_proofs;
        uint256[] memory entropy = new uint256[](num_proofs);
        inputAccumulators = new uint256[](numPublicInputs + 1);

        for (uint256 proofNumber = 0; proofNumber < num_proofs; proofNumber++) {
            if (proofNumber == 0) {
                entropy[proofNumber] = 1;
            } else {
                // entropy
                entropy[proofNumber] = getProofEntropy(in_proof, proof_inputs, proofNumber);
            }
            require(entropy[proofNumber] != 0, "Entropy should not be zero");
            // here multiplication by 1 is for a sake of clarity only
            inputAccumulators[0] = addmod(inputAccumulators[0], mulmod(1, entropy[proofNumber], q), q);
            for (uint256 i = 0; i < numPublicInputs; i++) {
                // TODO
                // require(proof_inputs[proofNumber * numPublicInputs + i] < q, "INVALID_INPUT");
                // accumulate the exponent with extra entropy mod q
                inputAccumulators[i + 1] = addmod(inputAccumulators[i + 1], mulmod(entropy[proofNumber], proof_inputs[proofNumber * numPublicInputs + i], q), q);
            }
            // coefficient for +vk.alpha (mind +)
            // accumulators[0] = addmod(accumulators[0], entropy[proofNumber], q); // that's the same as inputAccumulators[0]
        }

        // inputs for scalar multiplication
        uint256[3] memory mul_input;
        bool success;

        // use scalar multiplications to get proof.A[i] * entropy[i]

        proofsAandC = new uint256[](num_proofs * 2 + 2);

        proofsAandC[0] = in_proof[0];
        proofsAandC[1] = in_proof[1];

        for (uint256 proofNumber = 1; proofNumber < num_proofs; proofNumber++) {
            require(entropy[proofNumber] < q, "INVALID_INPUT");
            mul_input[0] = in_proof[proofNumber * 8];
            mul_input[1] = in_proof[proofNumber * 8 + 1];
            mul_input[2] = entropy[proofNumber];
            assembly {
            // ECMUL, output proofsA[i]
            // success := staticcall(sub(gas(), 2000), 7, mul_input, 0x60, add(add(proofsAandC, 0x20), mul(proofNumber, 0x40)), 0x40)
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x60, mul_input, 0x40)
            }
            proofsAandC[proofNumber * 2] = mul_input[0];
            proofsAandC[proofNumber * 2 + 1] = mul_input[1];
            require(success, "Failed to call a precompile");
        }

        // use scalar multiplication and addition to get sum(proof.C[i] * entropy[i])

        uint256[4] memory add_input;

        add_input[0] = in_proof[6];
        add_input[1] = in_proof[7];

        for (uint256 proofNumber = 1; proofNumber < num_proofs; proofNumber++) {
            mul_input[0] = in_proof[proofNumber * 8 + 6];
            mul_input[1] = in_proof[proofNumber * 8 + 7];
            mul_input[2] = entropy[proofNumber];
            assembly {
            // ECMUL, output proofsA
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x60, add(add_input, 0x40), 0x40)
            }
            require(success, "Failed to call a precompile for G1 multiplication for Proof C");

            assembly {
            // ECADD from two elements that are in add_input and output into first two elements of add_input
                success := staticcall(sub(gas(), 2000), 6, add_input, 0x80, add_input, 0x40)
            }
            require(success, "Failed to call a precompile for G1 addition for Proof C");
        }

        proofsAandC[num_proofs * 2] = add_input[0];
        proofsAandC[num_proofs * 2 + 1] = add_input[1];
    }

    function prepareBatches(
        uint256[14] memory in_vk,
        uint256[] memory vk_gammaABC,
        uint256[] memory inputAccumulators
    ) internal view returns (
        uint256[4] memory finalVksAlphaX
    ) {
        // Compute the linear combination vk_x using accumulator
        // First two fields are used as the sum and are initially zero
        uint256[4] memory add_input;
        uint256[3] memory mul_input;
        bool success;

        // Performs a sum(gammaABC[i] * inputAccumulator[i])
        for (uint256 i = 0; i < inputAccumulators.length; i++) {
            mul_input[0] = vk_gammaABC[2 * i];
            mul_input[1] = vk_gammaABC[2 * i + 1];
            mul_input[2] = inputAccumulators[i];

            assembly {
            // ECMUL, output to the last 2 elements of `add_input`
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x60, add(add_input, 0x40), 0x40)
            }
            require(success, "Failed to call a precompile for G1 multiplication for input accumulator");

            assembly {
            // ECADD from four elements that are in add_input and output into first two elements of add_input
                success := staticcall(sub(gas(), 2000), 6, add_input, 0x80, add_input, 0x40)
            }
            require(success, "Failed to call a precompile for G1 addition for input accumulator");
        }

        finalVksAlphaX[2] = add_input[0];
        finalVksAlphaX[3] = add_input[1];

        // add one extra memory slot for scalar for multiplication usage
        uint256[3] memory finalVKalpha;
        finalVKalpha[0] = in_vk[0];
        finalVKalpha[1] = in_vk[1];
        finalVKalpha[2] = inputAccumulators[0];

        assembly {
        // ECMUL, output to first 2 elements of finalVKalpha
            success := staticcall(sub(gas(), 2000), 7, finalVKalpha, 0x60, finalVKalpha, 0x40)
        }
        require(success, "Failed to call a precompile for G1 multiplication");
        finalVksAlphaX[0] = finalVKalpha[0];
        finalVksAlphaX[1] = finalVKalpha[1];
    }





    function verifyingKey(uint16 block_size) internal pure returns (uint256[14] memory vk) {
        if (block_size == 1) {
            vk[0] = 9592550698677262601935116295669176728057163231482534954958926912959923197735;
            vk[1] = 16733023998522933914236445194025947579333438163615544921452025491195899469175;
            vk[2] = 3465796397996106721591301614900111018730873894556020945016908279260230609925;
            vk[3] = 14710292704098646024162394377640898961931623132799749249793876365855882143010;
            vk[4] = 1230217388682189503284729494297697121484094837122580808755350572678900027881;
            vk[5] = 15026658955292522675978395366674558489873826270519528063515607979639972473999;
            vk[6] = 18609161028320746268319423907667488633298122476854998022249032420398719788342;
            vk[7] = 13960617452498475324228448614477857556081267343377899009211447948079920702063;
            vk[8] = 638593730005894791697370983423197410522639465790872529786907186448042604185;
            vk[9] = 1141271081801350296357941499005058111315680603481381503697303690166263590213;
            vk[10] = 209148050134373040332877707637516437493705556967030276075347705023877778078;
            vk[11] = 13036109057497998482031791777538587980214650029770227722553055947023837823390;
            vk[12] = 7920457489318388416129029439378003055643814132016693330129429278057090330301;
            vk[13] = 11107926130640246464539195059399943021499464816006944237863650243086630869784;
            return vk;
        } else if (block_size == 10) {
            vk[0] = 7109476098066300552453490172081497543833769904477629909373258603601244454121;
            vk[1] = 18137460389089133091155557354109288696293054256823900985983335778452755081210;
            vk[2] = 7154534536372927087992518473694737455897213956854152098122469484370455265292;
            vk[3] = 6908464575573655408646182829841137045957433250459107300365806427977516003523;
            vk[4] = 61681643819594616496002287456905682746694115140496673998186468482763639422;
            vk[5] = 17956636511629054201339684575245726145307395287740492214737751168756359242798;
            vk[6] = 13023003731961002409007180472262462878454472637786402015236609981515229783638;
            vk[7] = 14653169097977411020176424368737721740697128081484002307519084082825482693917;
            vk[8] = 11773697092979022254223146437974376504776342335957584582583393413593369294562;
            vk[9] = 21005707496154691462158400318670231791671889755529462807134046442176884649421;
            vk[10] = 18101731089605952227121408059000631011416813058282501084604220305423155209255;
            vk[11] = 15915045061816324097774418450546280248702199828598416324657373162281413541763;
            vk[12] = 6445711823140795118356201724327019573950364018127964136940356778497407440745;
            vk[13] = 9822429127603350223598391502016376017850494540651889193283515110275290829382;
            return vk;
        } else {
            revert("u");
        }
    }

    function ic(uint16 block_size) internal pure returns (uint256[] memory gammaABC) {
        if (block_size == 1) {
            gammaABC = new uint256[](4);
            gammaABC[0] = 7397654588482528758829032958495511518846957066863554870511499061343625240637;
            gammaABC[1] = 17467761293510463375934899249006547150431575446051973331315313504537913247766;
            gammaABC[2] = 10528257627244240395004205616861856869379168601878926774984323055912051354131;
            gammaABC[3] = 14343820048327967593729641504253709348099849331414420846761051599212895144642;
            return gammaABC;
        } else if (block_size == 10) {
            gammaABC = new uint256[](4);
            gammaABC[0] = 19427186376489325204507852164013683659206898974374243788444267861619949043327;
            gammaABC[1] = 12070000976966717868038561788033066863164610890500019769110880475440066086334;
            gammaABC[2] = 9041003418071278445737113284662121943669488607247536233714007024588181336599;
            gammaABC[3] = 10501882477174173565865171262596862941478767696613889359416928776628180297099;
            return gammaABC;
        } else {
            revert("u");
        }
    }






    function getProofEntropy(
        uint256[] memory in_proof,
        uint256[] memory proof_inputs,
        uint proofNumber
    )
    internal pure returns (uint256)
    {
        // Truncate the least significant 3 bits from the 256bit entropy so it fits the scalar field
        return uint256(
            keccak256(
                abi.encodePacked(
                    in_proof[proofNumber * 8 + 0], in_proof[proofNumber * 8 + 1], in_proof[proofNumber * 8 + 2], in_proof[proofNumber * 8 + 3],
                    in_proof[proofNumber * 8 + 4], in_proof[proofNumber * 8 + 5], in_proof[proofNumber * 8 + 6], in_proof[proofNumber * 8 + 7],
                    proof_inputs[proofNumber]
                )
            )
        ) >> 3;
    }

    // original equation 
    // e(proof.A, proof.B)*e(-vk.alpha, vk.beta)*e(-vk_x, vk.gamma)*e(-proof.C, vk.delta) == 1
    // accumulation of inputs
    // gammaABC[0] + sum[ gammaABC[i+1]^proof_inputs[i] ]

    function verifyBatchProofs(
        uint256[] memory in_proof, // proof itself, length is 8 * num_proofs
        uint256[] memory proof_inputs, // public inputs, length is num_inputs * num_proofs
        uint256 num_proofs,
        uint16 block_size
    )
    public
    view
    returns (bool success)
    {
        if (num_proofs == 1) {
            return verifyProof(in_proof, proof_inputs, block_size);
        }
        uint256[14] memory in_vk = verifyingKey(block_size);
        uint256[] memory vk_gammaABC = ic(block_size);
        require(in_proof.length == 8 * num_proofs, "Invalid proofs length for a batch");
        require(proof_inputs.length % num_proofs == 0, "Invalid inputs length for a batch");
        require(((vk_gammaABC.length / 2) - 1) == proof_inputs.length / num_proofs, "Mismatching number of inputs for verifying key");

        // strategy is to accumulate entropy separately for all the "constant" elements
        // (accumulate only for G1, can't in G2) of the pairing equation, as well as input verification key,
        // postpone scalar multiplication as much as possible and check only one equation 
        // by using 3+num_proofs pairings only

        uint256[] memory proofsAandC;
        uint256[] memory inputAccumulators;
        (proofsAandC, inputAccumulators) = accumulate(in_proof, proof_inputs, num_proofs);

        uint256[4] memory finalVksAlphaX = prepareBatches(in_vk, vk_gammaABC, inputAccumulators);

        uint256[] memory inputs = new uint256[](6 * num_proofs + 18);
        // first num_proofs pairings e(ProofA, ProofB)
        for (uint256 proofNumber = 0; proofNumber < num_proofs; proofNumber++) {
            inputs[proofNumber * 6] = proofsAandC[proofNumber * 2];
            inputs[proofNumber * 6 + 1] = proofsAandC[proofNumber * 2 + 1];
            inputs[proofNumber * 6 + 2] = in_proof[proofNumber * 8 + 2];
            inputs[proofNumber * 6 + 3] = in_proof[proofNumber * 8 + 3];
            inputs[proofNumber * 6 + 4] = in_proof[proofNumber * 8 + 4];
            inputs[proofNumber * 6 + 5] = in_proof[proofNumber * 8 + 5];
        }

        // second pairing e(-finalVKaplha, vk.beta)
        inputs[num_proofs * 6] = finalVksAlphaX[0];
        inputs[num_proofs * 6 + 1] = NegateY(finalVksAlphaX[1]);
        inputs[num_proofs * 6 + 2] = in_vk[2];
        inputs[num_proofs * 6 + 3] = in_vk[3];
        inputs[num_proofs * 6 + 4] = in_vk[4];
        inputs[num_proofs * 6 + 5] = in_vk[5];

        // third pairing e(-finalVKx, vk.gamma)
        inputs[num_proofs * 6 + 6] = finalVksAlphaX[2];
        inputs[num_proofs * 6 + 7] = NegateY(finalVksAlphaX[3]);
        inputs[num_proofs * 6 + 8] = in_vk[6];
        inputs[num_proofs * 6 + 9] = in_vk[7];
        inputs[num_proofs * 6 + 10] = in_vk[8];
        inputs[num_proofs * 6 + 11] = in_vk[9];

        // fourth pairing e(-proof.C, finalVKdelta)
        inputs[num_proofs * 6 + 12] = proofsAandC[num_proofs * 2];
        inputs[num_proofs * 6 + 13] = NegateY(proofsAandC[num_proofs * 2 + 1]);
        inputs[num_proofs * 6 + 14] = in_vk[10];
        inputs[num_proofs * 6 + 15] = in_vk[11];
        inputs[num_proofs * 6 + 16] = in_vk[12];
        inputs[num_proofs * 6 + 17] = in_vk[13];

        uint256 inputsLength = inputs.length * 32;
        uint[1] memory out;
        require(inputsLength % 192 == 0, "Inputs length should be multiple of 192 bytes");

        // return true;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(inputs, 0x20), inputsLength, out, 0x20)
        }
        require(success, "Failed to call pairings functions");
        return out[0] == 1;
    }

    function verifyProof(
        uint256[] memory in_proof,
        uint256[] memory proof_inputs,
        uint16 block_size)
    public
    view
    returns (bool)
    {
        uint256[14] memory in_vk = verifyingKey(block_size);
        uint256[] memory vk_gammaABC = ic(block_size);
        require(((vk_gammaABC.length / 2) - 1) == proof_inputs.length);
        require(in_proof.length == 8);
        // Compute the linear combination vk_x
        uint256[3] memory mul_input;
        uint256[4] memory add_input;
        bool success;
        uint m = 2;

        // First two fields are used as the sum
        add_input[0] = vk_gammaABC[0];
        add_input[1] = vk_gammaABC[1];

        uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        // Performs a sum of gammaABC[0] + sum[ gammaABC[i+1]^proof_inputs[i] ]
        for (uint i = 0; i < proof_inputs.length; i++) {
            // @dev only for qa test
            //  require(proof_inputs[i] < q, "INVALID_INPUT");
            mul_input[0] = vk_gammaABC[m++];
            mul_input[1] = vk_gammaABC[m++];
            mul_input[2] = proof_inputs[i];

            assembly {
            // ECMUL, output to last 2 elements of `add_input`
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x80, add(add_input, 0x40), 0x60)
            }
            require(success);

            assembly {
            // ECADD
                success := staticcall(sub(gas(), 2000), 6, add_input, 0xc0, add_input, 0x60)
            }
            require(success);
        }

        uint[24] memory input = [
        // (proof.A, proof.B)
        in_proof[0], in_proof[1], // proof.A   (G1)
        in_proof[2], in_proof[3], in_proof[4], in_proof[5], // proof.B   (G2)

        // (-vk.alpha, vk.beta)
        in_vk[0], NegateY(in_vk[1]), // -vk.alpha (G1)
        in_vk[2], in_vk[3], in_vk[4], in_vk[5], // vk.beta   (G2)

        // (-vk_x, vk.gamma)
        add_input[0], NegateY(add_input[1]), // -vk_x     (G1)
        in_vk[6], in_vk[7], in_vk[8], in_vk[9], // vk.gamma  (G2)

        // (-proof.C, vk.delta)
        in_proof[6], NegateY(in_proof[7]), // -proof.C  (G1)
        in_vk[10], in_vk[11], in_vk[12], in_vk[13]          // vk.delta  (G2)
        ];

        uint[1] memory out;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, 768, out, 0x20)
        }
        require(success);
        return out[0] == 1;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./SafeMathUInt128.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Utils.sol";

import "./Storage.sol";
import "./Config.sol";
import "./Events.sol";

import "./Bytes.sol";
import "./TxTypes.sol";

import "./UpgradeableMaster.sol";

/// @title ZkBNB additional main contract
/// @author ZkBNB
contract AdditionalZkBNB is Storage, Config, Events, ReentrancyGuard, IERC721Receiver {
    using SafeMath for uint256;
    using SafeMathUInt128 for uint128;

    function increaseBalanceToWithdraw(bytes22 _packedBalanceKey, uint128 _amount) internal {
        uint128 balance = pendingBalances[_packedBalanceKey].balanceToWithdraw;
        pendingBalances[_packedBalanceKey] = PendingBalance(balance.add(_amount), FILLED_GAS_RESERVE_VALUE);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4){
        return this.onERC721Received.selector;
    }

    /*
        StateRoot
            AccountRoot
            NftRoot
        Account
            AccountIndex
            AccountNameHash bytes32
            PublicKey
            AssetRoot
        Asset
           AssetId
           Balance
        Nft
    */
    function performDesert(
        StoredBlockInfo memory _storedBlockInfo,
        address _owner,
        uint32 _accountId,
        uint32 _tokenId,
        uint128 _amount
    ) external {
        require(_accountId <= MAX_ACCOUNT_INDEX, "e");
        require(_accountId != SPECIAL_ACCOUNT_ID, "v");

        require(desertMode, "s");
        // must be in exodus mode
        require(!performedDesert[_accountId][_tokenId], "t");
        // already exited
        require(storedBlockHashes[totalBlocksVerified] == hashStoredBlockInfo(_storedBlockInfo), "u");
        // incorrect stored block info

        // TODO
        //        bool proofCorrect = verifier.verifyExitProof(
        //            _storedBlockHeader.accountRoot,
        //            _accountId,
        //            _owner,
        //            _tokenId,
        //            _amount,
        //            _nftCreatorAccountId,
        //            _nftCreatorAddress,
        //            _nftSerialId,
        //            _nftContentHash,
        //            _proof
        //        );
        //        require(proofCorrect, "x");

        if (_tokenId <= MAX_FUNGIBLE_ASSET_ID) {
            bytes22 packedBalanceKey = packAddressAndAssetId(_owner, uint16(_tokenId));
            increaseBalanceToWithdraw(packedBalanceKey, _amount);
        } else {
            // TODO
            require(_amount != 0, "Z");
            // Unsupported nft amount
            //            TxTypes.WithdrawNFT memory withdrawNftOp = TxTypes.WithdrawNFT({
            //            txType : uint8(TxTypes.TxType.WithdrawNFT),
            //            accountIndex : _nftCreatorAccountId,
            //            toAddress : _nftCreatorAddress,
            //            proxyAddress : _nftCreatorAddress,
            //            nftAssetId : _nftSerialId,
            //            gasFeeAccountIndex : 0,
            //            gasFeeAssetId : 0,
            //            gasFeeAssetAmount : 0
            //            });
            //            pendingWithdrawnNFTs[_tokenId] = withdrawNftOp;
            //            emit WithdrawalNFTPending(_tokenId);
        }
        performedDesert[_accountId][_tokenId] = true;
    }

    function cancelOutstandingDepositsForExodusMode(uint64 _n, bytes[] memory _depositsPubData) external {
        require(desertMode, "8");
        // exodus mode not active
        uint64 toProcess = Utils.minU64(totalOpenPriorityRequests, _n);
        require(toProcess > 0, "9");
        // no deposits to process
        uint64 currentDepositIdx = 0;
        for (uint64 id = firstPriorityRequestId; id < firstPriorityRequestId + toProcess; id++) {
            if (priorityRequests[id].txType == TxTypes.TxType.Deposit) {
                bytes memory depositPubdata = _depositsPubData[currentDepositIdx];
                require(Utils.hashBytesToBytes20(depositPubdata) == priorityRequests[id].hashedPubData, "a");
                ++currentDepositIdx;

                // TODO get address by account name
                address owner = address(0x0);
                TxTypes.Deposit memory _tx = TxTypes.readDepositPubData(depositPubdata);
                bytes22 packedBalanceKey = packAddressAndAssetId(owner, uint16(_tx.assetId));
                pendingBalances[packedBalanceKey].balanceToWithdraw += _tx.amount;
            }
            delete priorityRequests[id];
        }
        firstPriorityRequestId += toProcess;
        totalOpenPriorityRequests -= toProcess;
    }

    // TODO
    uint256 internal constant SECURITY_COUNCIL_2_WEEKS_THRESHOLD = 3;
    uint256 internal constant SECURITY_COUNCIL_1_WEEK_THRESHOLD = 2;
    uint256 internal constant SECURITY_COUNCIL_3_DAYS_THRESHOLD = 1;

    function cutUpgradeNoticePeriod() external {
        requireActive();

        address payable[SECURITY_COUNCIL_MEMBERS_NUMBER] memory SECURITY_COUNCIL_MEMBERS = [
        payable(0x00), payable(0x00), payable(0x00)
        ];
        for (uint256 id = 0; id < SECURITY_COUNCIL_MEMBERS_NUMBER; ++id) {
            if (SECURITY_COUNCIL_MEMBERS[id] == msg.sender) {
                require(upgradeStartTimestamp != 0);
                require(securityCouncilApproves[id] == false);
                securityCouncilApproves[id] = true;
                numberOfApprovalsFromSecurityCouncil++;

                if (numberOfApprovalsFromSecurityCouncil == SECURITY_COUNCIL_2_WEEKS_THRESHOLD) {
                    if (approvedUpgradeNoticePeriod > 2 weeks) {
                        approvedUpgradeNoticePeriod = 2 weeks;
                        emit NoticePeriodChange(approvedUpgradeNoticePeriod);
                    }
                } else if (numberOfApprovalsFromSecurityCouncil == SECURITY_COUNCIL_1_WEEK_THRESHOLD) {
                    if (approvedUpgradeNoticePeriod > 1 weeks) {
                        approvedUpgradeNoticePeriod = 1 weeks;
                        emit NoticePeriodChange(approvedUpgradeNoticePeriod);
                    }
                } else if (numberOfApprovalsFromSecurityCouncil == SECURITY_COUNCIL_3_DAYS_THRESHOLD) {
                    if (approvedUpgradeNoticePeriod > 3 days) {
                        approvedUpgradeNoticePeriod = 3 days;
                        emit NoticePeriodChange(approvedUpgradeNoticePeriod);
                    }
                }

                break;
            }
        }
    }

    /// @notice Reverts unverified blocks
    function revertBlocks(StoredBlockInfo[] memory _blocksToRevert) external {
        requireActive();

        governance.requireActiveValidator(msg.sender);

        uint32 blocksCommitted = totalBlocksCommitted;
        uint32 blocksToRevert = Utils.minU32(uint32(_blocksToRevert.length), blocksCommitted - totalBlocksVerified);
        uint64 revertedPriorityRequests = 0;

        for (uint32 i = 0; i < blocksToRevert; ++i) {
            StoredBlockInfo memory storedBlockInfo = _blocksToRevert[i];
            require(storedBlockHashes[blocksCommitted] == hashStoredBlockInfo(storedBlockInfo), "r");
            // incorrect stored block info

            delete storedBlockHashes[blocksCommitted];

            --blocksCommitted;
            revertedPriorityRequests += storedBlockInfo.priorityOperations;
        }

        totalBlocksCommitted = blocksCommitted;
        totalCommittedPriorityRequests -= revertedPriorityRequests;
        if (totalBlocksCommitted < totalBlocksVerified) {
            totalBlocksVerified = totalBlocksCommitted;
        }

        emit BlocksRevert(totalBlocksVerified, blocksCommitted);
    }

    /// @notice Set default factory for our contract. This factory will be used to mint an NFT token that has no factory
    /// @param _factory Address of NFT factory
    function setDefaultNFTFactory(NFTFactory _factory) external {
        governance.requireGovernor(msg.sender);
        require(address(_factory) != address(0), "mb1");
        // Factory should be non zero
        require(address(defaultNFTFactory) == address(0), "mb2");
        // NFTFactory is already set
        defaultNFTFactory = address(_factory);
        emit NewDefaultNFTFactory(address(_factory));
    }

    /// @notice Register NFTFactory to this contract
    /// @param _creatorAccountName accountName of the creator
    /// @param _collectionId collection Id of the NFT related to this creator
    /// @param _factory NFT Factory
    function registerNFTFactory(
        string calldata _creatorAccountName,
        uint32 _collectionId,
        NFTFactory _factory
    ) external {
        bytes32 creatorAccountNameHash = znsController.getSubnodeNameHash(_creatorAccountName);
        require(znsController.isRegisteredNameHash(creatorAccountNameHash), "nr");
        require(address(nftFactories[creatorAccountNameHash][_collectionId]) == address(0), "Q");
        // Check check accountNameHash belongs to msg.sender
        address creatorAddress = getAddressByAccountNameHash(creatorAccountNameHash);
        require(creatorAddress == msg.sender, 'ns');

        nftFactories[creatorAccountNameHash][_collectionId] = address(_factory);
        emit NewNFTFactory(creatorAccountNameHash, _collectionId, address(_factory));
    }

    /// @notice Saves priority request in storage
    /// @dev Calculates expiration block for request, store this request and emit NewPriorityRequest event
    /// @param _txType Rollup _tx type
    /// @param _pubData _tx pub data
    function addPriorityRequest(TxTypes.TxType _txType, bytes memory _pubData) internal {
        // Expiration block is: current block number + priority expiration delta
        uint64 expirationBlock = uint64(block.number + PRIORITY_EXPIRATION);

        uint64 nextPriorityRequestId = firstPriorityRequestId + totalOpenPriorityRequests;

        bytes20 hashedPubData = Utils.hashBytesToBytes20(_pubData);

        priorityRequests[nextPriorityRequestId] = PriorityTx({
        hashedPubData : hashedPubData,
        expirationBlock : expirationBlock,
        txType : _txType
        });

        emit NewPriorityRequest(msg.sender, nextPriorityRequestId, _txType, _pubData, uint256(expirationBlock));

        totalOpenPriorityRequests++;
    }

    function getAddressByAccountNameHash(bytes32 accountNameHash) public view returns (address){
        return znsController.getOwner(accountNameHash);
    }

    /// @notice Register full exit request - pack pubdata, add priority request
    /// @param _accountName account name
    /// @param _asset Token address, 0 address for BNB
    function requestFullExit(string calldata _accountName, address _asset) public {
        requireActive();
        bytes32 accountNameHash = znsController.getSubnodeNameHash(_accountName);
        require(znsController.isRegisteredNameHash(accountNameHash), "nr");
        // get address by account name hash
        address creatorAddress = getAddressByAccountNameHash(accountNameHash);
        require(msg.sender == creatorAddress, "ia");

        uint16 assetId;
        if (_asset == address(0)) {
            assetId = 0;
        } else {
            assetId = governance.validateAssetAddress(_asset);
        }

        // Priority Queue request
        TxTypes.FullExit memory _tx = TxTypes.FullExit({
        txType : uint8(TxTypes.TxType.FullExit),
        accountIndex : 0, // unknown at this point
        accountNameHash : accountNameHash,
        assetId : assetId,
        assetAmount : 0 // unknown at this point
        });
        bytes memory pubData = TxTypes.writeFullExitPubDataForPriorityQueue(_tx);
        addPriorityRequest(TxTypes.TxType.FullExit, pubData);

        // User must fill storage slot of balancesToWithdraw(msg.sender, tokenId) with nonzero value
        // In this case operator should just overwrite this slot during confirming withdrawal
        bytes22 packedBalanceKey = packAddressAndAssetId(msg.sender, assetId);
        pendingBalances[packedBalanceKey].gasReserveValue = FILLED_GAS_RESERVE_VALUE;
    }

    /// @notice Register full exit nft request - pack pubdata, add priority request
    /// @param _accountName account name
    /// @param _nftIndex account NFT index in zkbnb network
    function requestFullExitNft(string calldata _accountName, uint32 _nftIndex) public {
        requireActive();
        bytes32 accountNameHash = znsController.getSubnodeNameHash(_accountName);
        require(znsController.isRegisteredNameHash(accountNameHash), "nr");
        require(_nftIndex < MAX_NFT_INDEX, "T");
        // get address by account name hash
        address creatorAddress = getAddressByAccountNameHash(accountNameHash);
        require(msg.sender == creatorAddress, "ia");

        // Priority Queue request
        TxTypes.FullExitNft memory _tx = TxTypes.FullExitNft({
        txType : uint8(TxTypes.TxType.FullExitNft),
        accountIndex : 0, // unknown
        creatorAccountIndex : 0, // unknown
        creatorTreasuryRate : 0,
        nftIndex : _nftIndex,
        collectionId : 0, // unknown
        nftL1Address : address(0x0), // unknown
        accountNameHash : accountNameHash,
        creatorAccountNameHash : bytes32(0),
        nftContentHash : bytes32(0x0), // unknown,
        nftL1TokenId : 0 // unknown
        });
        bytes memory pubData = TxTypes.writeFullExitNftPubDataForPriorityQueue(_tx);
        addPriorityRequest(TxTypes.TxType.FullExitNft, pubData);
    }

    /// @notice Register deposit request - pack pubdata, add into onchainOpsCheck and emit OnchainDeposit event
    /// @param _assetId Asset by id
    /// @param _amount Asset amount
    /// @param _accountNameHash Receiver Account Name
    function registerDeposit(
        uint16 _assetId,
        uint128 _amount,
        bytes32 _accountNameHash
    ) internal {
        // Priority Queue request
        TxTypes.Deposit memory _tx = TxTypes.Deposit({
        txType : uint8(TxTypes.TxType.Deposit),
        accountIndex : 0, // unknown at the moment
        accountNameHash : _accountNameHash,
        assetId : _assetId,
        amount : _amount
        });
        // compact pub data
        bytes memory pubData = TxTypes.writeDepositPubDataForPriorityQueue(_tx);
        // add into priority request queue
        addPriorityRequest(TxTypes.TxType.Deposit, pubData);
        emit Deposit(_assetId, _accountNameHash, _amount);
    }

    event NewZkBNBVerifier(address verifier);

    bytes32 private constant EMPTY_STRING_KECCAK = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    struct CommitBlockInfo {
        bytes32 newStateRoot;
        bytes publicData;
        uint256 timestamp;
        uint32[] publicDataOffsets;
        uint32 blockNumber;
        uint16 blockSize;
    }

    function commitBlocks(
        StoredBlockInfo memory _lastCommittedBlockData,
        CommitBlockInfo[] memory _newBlocksData
    )
    external
    {
        requireActive();
        governance.requireActiveValidator(msg.sender);
        // Check that we commit blocks after last committed block
        // incorrect previous block data
        require(storedBlockHashes[totalBlocksCommitted] == hashStoredBlockInfo(_lastCommittedBlockData), "i");

        for (uint32 i = 0; i < _newBlocksData.length; ++i) {
            _lastCommittedBlockData = commitOneBlock(_lastCommittedBlockData, _newBlocksData[i]);

            totalCommittedPriorityRequests += _lastCommittedBlockData.priorityOperations;
            storedBlockHashes[_lastCommittedBlockData.blockNumber] = hashStoredBlockInfo(_lastCommittedBlockData);

            emit BlockCommit(_lastCommittedBlockData.blockNumber);
        }

        totalBlocksCommitted += uint32(_newBlocksData.length);

        require(totalCommittedPriorityRequests <= totalOpenPriorityRequests, "j");
    }

    /// @dev Process one block commit using previous block StoredBlockInfo,
    /// @dev returns new block StoredBlockInfo
    function commitOneBlock(StoredBlockInfo memory _previousBlock, CommitBlockInfo memory _newBlock)
    internal
    view
    returns (StoredBlockInfo memory storedNewBlock)
    {
        // only commit next block
        require(_newBlock.blockNumber == _previousBlock.blockNumber + 1, "f");

        // Check timestamp of the new block
        // Block should be after previous block
        {
            require(_newBlock.timestamp >= _previousBlock.timestamp, "g");
        }

        // Check onchain operations
        (
        bytes32 pendingOnchainOpsHash,
        uint64 priorityReqCommitted
        ) = collectOnchainOps(_newBlock);

        // Create block commitment for verification proof
        bytes32 commitment = createBlockCommitment(_previousBlock, _newBlock);

        return
        StoredBlockInfo(
            _newBlock.blockSize,
            _newBlock.blockNumber,
            priorityReqCommitted,
            pendingOnchainOpsHash,
            _newBlock.timestamp,
            _newBlock.newStateRoot,
            commitment
        );
    }

    function createBlockCommitment(
        StoredBlockInfo memory _previousBlock,
        CommitBlockInfo memory _newBlockData
    ) internal view returns (bytes32) {
        bytes32 converted = keccak256(abi.encodePacked(
                uint256(_newBlockData.blockNumber), // block number
                uint256(_newBlockData.timestamp), // time stamp
                _previousBlock.stateRoot, // old state root
                _newBlockData.newStateRoot, // new state root
                _newBlockData.publicData, // pub data
                uint256(_newBlockData.publicDataOffsets.length) // on chain ops count
            ));
        return converted;
    }

    /// @notice Collect onchain ops and ensure it was not executed before
    function collectOnchainOps(CommitBlockInfo memory _newBlockData)
    internal
    view
    returns (
        bytes32 processableOperationsHash,
        uint64 priorityOperationsProcessed
    )
    {
        bytes memory pubData = _newBlockData.publicData;

        require(pubData.length % TX_SIZE == 0, "A");

        uint64 uncommittedPriorityRequestsOffset = firstPriorityRequestId + totalCommittedPriorityRequests;
        priorityOperationsProcessed = 0;
        processableOperationsHash = EMPTY_STRING_KECCAK;

        for (uint16 i = 0; i < _newBlockData.publicDataOffsets.length; ++i) {
            uint32 pubdataOffset = _newBlockData.publicDataOffsets[i];
            require(pubdataOffset < pubData.length, "B");

            TxTypes.TxType txType = TxTypes.TxType(uint8(pubData[pubdataOffset+31]));

            if (txType == TxTypes.TxType.RegisterZNS) {
                bytes memory txPubData = Bytes.slice(pubData, pubdataOffset, TxTypes.PACKED_TX_PUBDATA_BYTES);

                TxTypes.RegisterZNS memory registerZNSData = TxTypes.readRegisterZNSPubData(txPubData);
                checkPriorityOperation(registerZNSData, uncommittedPriorityRequestsOffset + priorityOperationsProcessed);
                priorityOperationsProcessed++;
            } else if (txType == TxTypes.TxType.Deposit) {
                bytes memory txPubData = Bytes.slice(pubData, pubdataOffset, TxTypes.PACKED_TX_PUBDATA_BYTES);
                TxTypes.Deposit memory depositData = TxTypes.readDepositPubData(txPubData);
                checkPriorityOperation(depositData, uncommittedPriorityRequestsOffset + priorityOperationsProcessed);
                priorityOperationsProcessed++;
            } else if (txType == TxTypes.TxType.DepositNft) {
                bytes memory txPubData = Bytes.slice(pubData, pubdataOffset, TxTypes.PACKED_TX_PUBDATA_BYTES);

                TxTypes.DepositNft memory depositNftData = TxTypes.readDepositNftPubData(txPubData);
                checkPriorityOperation(depositNftData, uncommittedPriorityRequestsOffset + priorityOperationsProcessed);
                priorityOperationsProcessed++;
            } else {

                bytes memory txPubData;

                if (txType == TxTypes.TxType.Withdraw) {
                    txPubData = Bytes.slice(pubData, pubdataOffset, TxTypes.PACKED_TX_PUBDATA_BYTES);
                } else if (txType == TxTypes.TxType.WithdrawNft) {
                    txPubData = Bytes.slice(pubData, pubdataOffset, TxTypes.PACKED_TX_PUBDATA_BYTES);
                } else if (txType == TxTypes.TxType.FullExit) {
                    txPubData = Bytes.slice(pubData, pubdataOffset, TxTypes.PACKED_TX_PUBDATA_BYTES);

                    TxTypes.FullExit memory fullExitData = TxTypes.readFullExitPubData(txPubData);

                    checkPriorityOperation(
                        fullExitData,
                        uncommittedPriorityRequestsOffset + priorityOperationsProcessed
                    );
                    priorityOperationsProcessed++;
                } else if (txType == TxTypes.TxType.FullExitNft) {
                    txPubData = Bytes.slice(pubData, pubdataOffset, TxTypes.PACKED_TX_PUBDATA_BYTES);

                    TxTypes.FullExitNft memory fullExitNFTData = TxTypes.readFullExitNftPubData(txPubData);

                    checkPriorityOperation(
                        fullExitNFTData,
                        uncommittedPriorityRequestsOffset + priorityOperationsProcessed
                    );
                    priorityOperationsProcessed++;
                } else {
                    // unsupported _tx
                    revert("F");
                }
                processableOperationsHash = Utils.concatHash(processableOperationsHash, txPubData);
            }
        }
    }

    /// @notice Checks that register zns is same as _tx in priority queue
    /// @param _registerZNS register zns
    /// @param _priorityRequestId _tx's id in priority queue
    function checkPriorityOperation(TxTypes.RegisterZNS memory _registerZNS, uint64 _priorityRequestId) internal view {
        TxTypes.TxType priorReqType = priorityRequests[_priorityRequestId].txType;
        // incorrect priority _tx type
        require(priorReqType == TxTypes.TxType.RegisterZNS, "H");

        bytes20 hashedPubData = priorityRequests[_priorityRequestId].hashedPubData;
        require(TxTypes.checkRegisterZNSInPriorityQueue(_registerZNS, hashedPubData), "I");
    }

    /// @notice Checks that deposit is same as _tx in priority queue
    /// @param _deposit Deposit data
    /// @param _priorityRequestId _tx's id in priority queue
    function checkPriorityOperation(TxTypes.Deposit memory _deposit, uint64 _priorityRequestId) internal view {
        TxTypes.TxType priorReqType = priorityRequests[_priorityRequestId].txType;
        // incorrect priority _tx type
        require(priorReqType == TxTypes.TxType.Deposit, "H");

        bytes20 hashedPubData = priorityRequests[_priorityRequestId].hashedPubData;
        require(TxTypes.checkDepositInPriorityQueue(_deposit, hashedPubData), "I");
    }

    /// @notice Checks that deposit is same as _tx in priority queue
    /// @param _deposit Deposit data
    /// @param _priorityRequestId _tx's id in priority queue
    function checkPriorityOperation(TxTypes.DepositNft memory _deposit, uint64 _priorityRequestId) internal view {
        TxTypes.TxType priorReqType = priorityRequests[_priorityRequestId].txType;
        // incorrect priority _tx type
        require(priorReqType == TxTypes.TxType.DepositNft, "H");

        bytes20 hashedPubData = priorityRequests[_priorityRequestId].hashedPubData;
        require(TxTypes.checkDepositNftInPriorityQueue(_deposit, hashedPubData), "I");
    }

    /// @notice Checks that FullExit is same as _tx in priority queue
    /// @param _fullExit FullExit data
    /// @param _priorityRequestId _tx's id in priority queue
    function checkPriorityOperation(TxTypes.FullExit memory _fullExit, uint64 _priorityRequestId) internal view {
        TxTypes.TxType priorReqType = priorityRequests[_priorityRequestId].txType;
        // incorrect priority _tx type
        require(priorReqType == TxTypes.TxType.FullExit, "J");

        bytes20 hashedPubData = priorityRequests[_priorityRequestId].hashedPubData;
        require(TxTypes.checkFullExitInPriorityQueue(_fullExit, hashedPubData), "K");
    }

    /// @notice Checks that FullExitNFT is same as _tx in priority queue
    /// @param _fullExitNft FullExit nft data
    /// @param _priorityRequestId _tx's id in priority queue
    function checkPriorityOperation(TxTypes.FullExitNft memory _fullExitNft, uint64 _priorityRequestId) internal view {
        TxTypes.TxType priorReqType = priorityRequests[_priorityRequestId].txType;
        // incorrect priority _tx type
        require(priorReqType == TxTypes.TxType.FullExitNft, "J");

        bytes20 hashedPubData = priorityRequests[_priorityRequestId].hashedPubData;
        require(TxTypes.checkFullExitNftInPriorityQueue(_fullExitNft, hashedPubData), "K");
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import "./Multicallable.sol";
import "./profile/ABIResolver.sol";
import "./profile/AddrResolver.sol";
import "./profile/PubKeyResolver.sol";
import "./profile/NameResolver.sol";
import "../ZNS.sol";
import "./profile/ZkBNBPubKeyResolver.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * A simple resolver anyone can use; only allows the owner of a node to set its address.
 */
contract PublicResolver is
Multicallable,
ABIResolver,
AddrResolver,
NameResolver,
PubKeyResolver,
ZkBNBPubKeyResolver,
ReentrancyGuardUpgradeable
{
    ZNS zns;

    /**
     * @dev A mapping of operators. An address that is authorised for an address
     * may make any changes to the name that the owner could, but may not update
     * the set of authorisations.
     * (owner, operator) => approved
     */
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Logged when an operator is added or removed.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function initialize(bytes calldata initializationParameters) external initializer {
        __ReentrancyGuard_init();

        (
        address _zns
        ) = abi.decode(initializationParameters, (address));
        zns = ZNS(_zns);
    }

    function zkbnbPubKey(bytes32 node) override external view returns (bytes32 pubKeyX, bytes32 pubKeyY) {
        return zns.pubKey(node);
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) external {
        require(
            msg.sender != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
    public
    view
    returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    function isAuthorised(bytes32 node) internal view override returns (bool) {
        address owner = zns.owner(node);
        return owner == msg.sender || isApprovedForAll(owner, msg.sender);
    }

    function supportsInterface(bytes4 interfaceID)
    public
    pure
    override(
    Multicallable,
    ABIResolver,
    AddrResolver,
    NameResolver,
    PubKeyResolver,
    ZkBNBPubKeyResolver
    )
    returns (bool)
    {
        return super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./Governance.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Utils.sol";

/// @title Asset Governance Contract
/// @author ZkBNB Team
/// @notice Contract is used to allow anyone to add new ERC20 tokens to ZkBNB given sufficient payment
contract AssetGovernance is ReentrancyGuard {
    /// @notice Token lister added or removed (see `tokenLister`)
    event TokenListerUpdate(address indexed tokenLister, bool isActive);

    /// @notice Listing fee token set
    event ListingFeeTokenUpdate(IERC20 indexed newListingFeeToken, uint256 newListingFee);

    /// @notice Listing fee set
    event ListingFeeUpdate(uint256 newListingFee);

    /// @notice Maximum number of listed tokens updated
    event ListingCapUpdate(uint16 newListingCap);

    /// @notice The treasury (the account which will receive the fee) was updated
    event TreasuryUpdate(address newTreasury);

    /// @notice The treasury account index was updated
    event TreasuryAccountIndexUpdate(uint32 _newTreasuryAccountIndex);

    /// @notice ZkBNB governance contract
    Governance public governance;

    /// @notice Token used to collect listing fee for addition of new token to ZkBNB network
    IERC20 public listingFeeToken;

    /// @notice Token listing fee
    uint256 public listingFee;

    /// @notice Max number of tokens that can be listed using this contract
    uint16 public listingCap;

    /// @notice Addresses that can list tokens without fee
    mapping(address => bool) public tokenLister;

    /// @notice Address that collects listing payments
    address public treasury;

    /// @notice AccountIndex that collects listing payments
    uint32 public treasuryAccountIndex;

    constructor (
        address _governance,
        address _listingFeeToken,
        uint256 _listingFee,
        uint16 _listingCap,
        address _treasury,
        uint32 _treasuryAccountIndex
    ) {

        governance = Governance(_governance);
        listingFeeToken = IERC20(_listingFeeToken);
        listingFee = _listingFee;
        listingCap = _listingCap;
        treasury = _treasury;
        treasuryAccountIndex = _treasuryAccountIndex;
        // We add treasury as the first token lister
        tokenLister[treasury] = true;
        emit TokenListerUpdate(treasury, true);
    }

    /// @notice Governance contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    // solhint-disable-next-line no-empty-blocks
    function upgrade(bytes calldata upgradeParameters) external {}

    /// @notice Adds new ERC20 token to ZkBNB network.
    /// @notice If caller is not present in the `tokenLister` map, payment of `listingFee` in `listingFeeToken` should be made.
    /// @notice NOTE: before calling this function make sure to approve `listingFeeToken` transfer for this contract.
    function addAsset(address _assetAddress) external {
        require(governance.totalAssets() < listingCap, "can't add more tokens");
        // Impossible to add more tokens using this contract
        if (!tokenLister[msg.sender]) {
            // Collect fees
            bool feeTransferOk = Utils.transferFromERC20(listingFeeToken, msg.sender, treasury, listingFee);
            require(feeTransferOk, "fee transfer failed");
            // Failed to receive payment for token addition.
        }
        governance.addAsset(_assetAddress);
    }

    /// Governance functions (this contract is governed by ZkBNB governor)

    /// @notice Set new listing token and fee
    /// @notice Can be called only by ZkBNB governor
    function setListingFeeAsset(IERC20 _newListingFeeAsset, uint256 _newListingFee) external {
        governance.requireGovernor(msg.sender);
        listingFeeToken = _newListingFeeAsset;
        listingFee = _newListingFee;

        emit ListingFeeTokenUpdate(_newListingFeeAsset, _newListingFee);
    }

    /// @notice Set new listing fee
    /// @notice Can be called only by ZkBNB governor
    function setListingFee(uint256 _newListingFee) external {
        governance.requireGovernor(msg.sender);
        listingFee = _newListingFee;

        emit ListingFeeUpdate(_newListingFee);
    }

    /// @notice Enable or disable token lister. If enabled new tokens can be added by that address without payment
    /// @notice Can be called only by ZkBNB governor
    function setLister(address _listerAddress, bool _active) external {
        governance.requireGovernor(msg.sender);
        if (tokenLister[_listerAddress] != _active) {
            tokenLister[_listerAddress] = _active;
            emit TokenListerUpdate(_listerAddress, _active);
        }
    }

    /// @notice Change maximum amount of tokens that can be listed using this method
    /// @notice Can be called only by ZkBNB governor
    function setListingCap(uint16 _newListingCap) external {
        governance.requireGovernor(msg.sender);
        listingCap = _newListingCap;

        emit ListingCapUpdate(_newListingCap);
    }

    /// @notice Change address that collects payments for listing tokens.
    /// @notice Can be called only by ZkBNB governor
    function setTreasury(address _newTreasury) external {
        governance.requireGovernor(msg.sender);
        treasury = _newTreasury;

        emit TreasuryUpdate(_newTreasury);
    }

    /// @notice Change account index that collects payments for listing tokens.
    /// @notice Can be called only by ZkBNB governor
    function setTreasuryAccountIndex(uint32 _newTreasuryAccountIndex) external {
        governance.requireGovernor(msg.sender);
        treasuryAccountIndex = _newTreasuryAccountIndex;

        emit TreasuryAccountIndexUpdate(_newTreasuryAccountIndex);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

interface IBaseRegistrar {

    event ControllerAdded(address indexed controller);

    event ControllerRemoved(address indexed controller);

    // Notify a node is registered.
    event ZNSRegistered(string name, bytes32 node, address owner, bytes32 pubKeyX, bytes32 pubKeyY, uint256 price);

    // Authorizes a controller, who can control this registrar.
    function addController(address controller) external;

    // Revoke controller permission for an address.
    function removeController(address controller) external;

    // Set resolver for the node this registrar manages.
    function setThisResolver(address resolver) external;

    // Register a node under the base node.
    function registerZNS(string calldata _name, address _owner, bytes32 zkbnbPubKeyX, bytes32 zkbnbPubKeyY, address _resolver) external payable returns (bytes32, uint32);
}

pragma solidity ^0.7.6;

interface IPriceOracle {
    /**
     * @dev Returns the price to register a name.
     * @param name The name being registered.
     * @return price
     */
    function price(string calldata name) external view returns (uint256);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

interface ZNS {

    // Logged when a node has new owner
    // Note that node is a namehash of a specified node, label is a namehash of subnode.
    event NewOwner(bytes32 indexed node, address owner);

    // Logged when the L2 owner of a node transfers ownership to a new L2 account.
    event NewPubKey(bytes32 indexed node, bytes32 pubKeyX, bytes32 pubKeyY);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    function setRecord(
        bytes32 _node,
        address _owner,
        bytes32 _pubKeyX,
        bytes32 _pubKeyY,
        address _resolver
    ) external;

    function setSubnodeRecord(
        bytes32 _node,
        bytes32 _label,
        address _owner,
        bytes32 _pubKeyX,
        bytes32 _pubKeyY,
        address _resolver
    ) external returns (bytes32);

    function setSubnodeAccountIndex(
        bytes32 _node
    ) external returns (uint32);

    function setSubnodeOwner(
        bytes32 _node,
        bytes32 _label,
        address _owner,
        bytes32 _pubKeyX,
        bytes32 _pubKeyY
    ) external returns (bytes32);

    function setResolver(bytes32 _node, address _resolver) external;

    function resolver(bytes32 node) external view returns (address);

    function owner(bytes32 node) external view returns (address);

    function pubKey(bytes32 node) external view returns (bytes32, bytes32);

    function recordExists(bytes32 node) external view returns (bool);

    function subNodeRecordExists(bytes32 node, bytes32 label) external view returns (bool);

}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

library Names {

    /**
     * @dev Returns the length of a given string, the length of each byte is self defined
     * @param s The string to measure the length of
     * @return The length of the input string
     */
    function strlen(string memory s) internal pure returns (uint) {
        uint len;
        uint i = 0;
        uint bytelength = bytes(s).length;
        for(len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if(b <= 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return len;
    }

    /**
     * @dev Returns if the char in this string is valid, the valid char set is self defined
     * @param s The string to validate
     * @return The length of the input string
     */
    function charsetValid(string memory s) internal pure returns (bool) {
        uint bytelength = bytes(s).length;
        for(uint i = 0; i < bytelength; i++) {
            bytes1 b = bytes(s)[i];
            if(!isValidCharacter(b)) {
                return false;
            }
        }
        return true;
    }

    // Only supports lowercase letters and digital number
    function isValidCharacter(bytes1 bs) internal pure returns (bool) {
        return (bs <= 0x39 && bs >= 0x30)       // number
                || (bs <= 0x7A && bs >= 0x61);  // lowercase letter
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "./IMulticallable.sol";
import "./SupportsInterface.sol";

abstract contract Multicallable is IMulticallable, SupportsInterface {
    function multicall(bytes[] calldata data) external override returns(bytes[] memory results) {
        results = new bytes[](data.length);
        for(uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success);
            results[i] = result;
        }
        return results;
    }

    function supportsInterface(bytes4 interfaceID) public override virtual pure returns(bool) {
        return interfaceID == type(IMulticallable).interfaceId || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./IABIResolver.sol";
import "../ResolverBase.sol";

abstract contract ABIResolver is IABIResolver, ResolverBase {
    mapping(bytes32 => mapping(uint256 => bytes)) abis;

    /**
     * Sets the ABI associated with an ZNS node.
     * Nodes may have one ABI of each content type. To remove an ABI, set it to the empty string.
     * @param node The node to update.
     * @param contentType The content type of the ABI
     * @param data The ABI data.
     */
    function setABI(bytes32 node, uint256 contentType, bytes calldata data) virtual external authorised(node) {
        // Content types must be powers of 2
        require(((contentType - 1) & contentType) == 0);

        abis[node][contentType] = data;
        emit ABIChanged(node, contentType);
    }

    /**
     * Returns the ABI associated with an ZNS node.
     * @param node The node to query
     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.
     * @return contentType The content type of the return value
     * @return data The ABI data
     */
    function ABI(bytes32 node, uint256 contentTypes) virtual override external view returns (uint256, bytes memory) {
        mapping(uint256 => bytes) storage abiset = abis[node];

        for (uint256 contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && abiset[contentType].length > 0) {
                return (contentType, abiset[contentType]);
            }
        }

        return (0, bytes(""));
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns (bool) {
        return interfaceID == type(IABIResolver).interfaceId || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../ResolverBase.sol";
import "./IAddrResolver.sol";
import "./IAddressResolver.sol";

abstract contract AddrResolver is IAddrResolver, ResolverBase {

    mapping(bytes32 => address) _addresses;

    /**
     * Sets the address associated with an ZNS node.
     * May only be called by the owner of that node in the ZNS registry.
     * @param node The node to update.
     * @param a The address to set.
     */
    function setAddr(bytes32 node, address a) virtual external authorised(node) {
        _addresses[node] = a;
        AddrChanged(node, a);
    }

    /**
     * Returns the address associated with an ZNS node.
     * @param node The node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) virtual override public view returns (address) {
        return _addresses[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == type(IAddrResolver).interfaceId || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./IPubKeyResolver.sol";
import "../ResolverBase.sol";

abstract contract PubKeyResolver is IPubKeyResolver, ResolverBase {
    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    mapping(bytes32 => PublicKey) pubkeys;

    /**
     * Sets the SECP256k1 public key associated with an ZNS node.
     * @param node The node to query
     * @param x the X coordinate of the curve point for the public key.
     * @param y the Y coordinate of the curve point for the public key.
     */
    function setPubKey(bytes32 node, bytes32 x, bytes32 y) virtual external authorised(node) {
        pubkeys[node] = PublicKey(x, y);
        emit PubKeyChanged(node, x, y);
    }

    /**
     * Returns the SECP256k1 public key in Layer 1 associated with an ZNS node.
     * @param node The node to query
     * @return x The X coordinate of the curve point for the public key.
     * @return y The Y coordinate of the curve point for the public key.
     */
    function pubKey(bytes32 node) virtual override external view returns (bytes32 x, bytes32 y) {
        return (pubkeys[node].x, pubkeys[node].y);
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns (bool) {
        return interfaceID == type(IPubKeyResolver).interfaceId || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../ResolverBase.sol";
import "./INameResolver.sol";

abstract contract NameResolver is INameResolver, ResolverBase {
    mapping(bytes32 => string) names;

    /**
     * Sets the name associated with an ZNS node, for reverse records.
     * May only be called by the owner of that node in the ZNS registry.
     * @param node The node to update.
     */
    function setName(bytes32 node, string calldata newName) virtual external authorised(node) {
        names[node] = newName;
        emit NameChanged(node, newName);
    }

    /**
     * Returns the name associated with an ZNS node, for reverse records.
     * @param node The node to query.
     * @return The associated name.
     */
    function name(bytes32 node) virtual override external view returns (string memory) {
        return names[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns (bool) {
        return interfaceID == type(INameResolver).interfaceId || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../ResolverBase.sol";
import "./IZkBNBPubKeyResolver.sol";
import "../../ZNS.sol";

abstract contract ZkBNBPubKeyResolver is IZkBNBPubKeyResolver, ResolverBase {

    /**
     * Returns the public key in L2 associated with an ZNS node.
     * @param node The node to query
     * @return pubKeyX The public key in L2 owns this node
     * @return pubKeyY The public key in L2 owns this node
     */
    function zkbnbPubKey(bytes32 node) virtual override external view returns (bytes32 pubKeyX, bytes32 pubKeyY);

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns (bool) {
        return interfaceID == type(IZkBNBPubKeyResolver).interfaceId || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

interface IMulticallable {
    function multicall(bytes[] calldata data) external returns(bytes[] memory results);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./ISupportsInterface.sol";

abstract contract SupportsInterface is ISupportsInterface {
    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == type(ISupportsInterface).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

interface ISupportsInterface {
    // @see The supportsInterface function is documented in EIP-165
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./IABIResolver.sol";
import "../ResolverBase.sol";

interface IABIResolver {
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    /**
     * Returns the ABI associated with an ZNS node.
     * @param node The node to query
     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.
     * @return contentType The content type of the return value
     * @return data The ABI data
     */
    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./SupportsInterface.sol";

abstract contract ResolverBase is SupportsInterface {
    function isAuthorised(bytes32 node) internal virtual view returns(bool);

    modifier authorised(bytes32 node) {
        require(isAuthorised(node));
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

/**
 * Interface for the legacy L1 addr function.
 */
interface IAddrResolver {
    event AddrChanged(bytes32 indexed node, address a);

    /**
     * Returns the L1 address associated with an node.
     * @param node The node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

/**
 * Interface for the new (multicoin) addr function.
 */
interface IAddressResolver {
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);

    function addr(bytes32 node, uint coinType) external view returns(bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

interface IPubKeyResolver {

    event PubKeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    /**
     * Returns the SECP256k1 public key in L1 associated with an ZNS node.
     * @param node The node to query
     * @return x The X coordinate of the curve point for the public key.
     * @return y The Y coordinate of the curve point for the public key.
     */
    function pubKey(bytes32 node) external view returns (bytes32 x, bytes32 y);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

interface INameResolver {
    event NameChanged(bytes32 indexed node, string name);

    /**
     * Returns the name associated with an ZNS node, for reverse records.
     * @param node The node to query.
     * @return The associated name.
     */
    function name(bytes32 node) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

interface IZkBNBPubKeyResolver {

    event ZkBNBPubKeyChanged(bytes32 indexed node, bytes32 pubKeyX, bytes32 pubKeyY);

    /**
     * Returns the public key in L2 associated with an ZNS node.
     * @param node The node to query
     * @return pubKeyX The public key in L2 owns this node
     * @return pubKeyY The public key in L2 owns this node
     */
    function zkbnbPubKey(bytes32 node) external view returns (bytes32 pubKeyX, bytes32 pubKeyY);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.6;

/// @title ZkBNBOwnable Contract
/// @author ZkBNB Team
contract ZkBNBOwnable {
    /// @dev Storage position of the masters address (keccak256('eip1967.proxy.admin') - 1)
    bytes32 private constant MASTER_POSITION = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /// @notice Contract constructor
    /// @dev Sets msg sender address as masters address
    /// @param masterAddress Master address
    constructor(address masterAddress) {
        setMaster(masterAddress);
    }

    /// @notice Check if specified address is master
    /// @param _address Address to check
    function requireMaster(address _address) internal view {
        require(_address == getMaster(), "1c");
        // oro11 - only by master
    }

    /// @notice Returns contract masters address
    /// @return master Master's address
    function getMaster() public view returns (address master) {
        bytes32 position = MASTER_POSITION;
        assembly {
            master := sload(position)
        }
    }

    /// @dev Sets new masters address
    /// @param _newMaster New master's address
    function setMaster(address _newMaster) internal {
        bytes32 position = MASTER_POSITION;
        assembly {
            sstore(position, _newMaster)
        }
    }

    /// @notice Transfer mastership of the contract to new master
    /// @param _newMaster New masters address
    function transferMastership(address _newMaster) external {
        requireMaster(msg.sender);
        require(_newMaster != address(0), "1d");
        // otp11 - new masters address can't be zero address
        setMaster(_newMaster);
    }
}