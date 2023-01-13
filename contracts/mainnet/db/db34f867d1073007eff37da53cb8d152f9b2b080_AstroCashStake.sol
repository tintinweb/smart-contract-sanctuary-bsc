/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

interface IERC1155 is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

contract WithdrawableOwnable is Ownable, ReentrancyGuard {
    using Address for address;

    function withdraw(uint256 amount) public virtual onlyOwner nonReentrant {
        uint256 balance = address(this).balance;

        require(
            amount <= balance,
            "Withdrawable: you cannot remove this total amount"
        );

        Address.sendValue(payable(_msgSender()), amount);

        emit Withdraw(_msgSender(), amount);
    }

    event Withdraw(address sender, uint256 value);

    function withdrawERC20(address tokenAddress, uint256 amount)
        external
        virtual
        nonReentrant
        onlyOwner
    {
        require(
            tokenAddress.isContract(),
            "Withdrawable: ERC20 token address must be a contract"
        );

        IERC20 tokenContract = IERC20(tokenAddress);

        uint256 balance = tokenContract.balanceOf(address(this));
        require(
            amount <= balance,
            "Withdrawable: you cannot remove this total amount"
        );

        require(
            tokenContract.transfer(_msgSender(), amount),
            "Withdrawable: Fail on transfer"
        );

        emit WithdrawERC20(_msgSender(), tokenAddress, amount);
    }

    event WithdrawERC20(address sender, address token, uint256 value);

    function withdrawERC721(address tokenAddress, uint256[] memory tokenIds)
        external
        virtual
        onlyOwner
        nonReentrant
    {
        require(
            tokenAddress.isContract(),
            "ERC721 token address must be a contract"
        );

        IERC721 tokenContract = IERC721(tokenAddress);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenContract.ownerOf(tokenIds[i]) == address(this),
                "This contract doesn't own the NFT you are trying to withdraw"
            );
            tokenContract.safeTransferFrom(
                address(this),
                _msgSender(),
                tokenIds[i]
            );
        }
        emit WithdrawERC721(tokenAddress, tokenIds);
    }

    event WithdrawERC721(address tokenAddress, uint256[] tokenIds);

    function withdrawERC1155(
        address tokenAddress,
        uint256 id,
        uint256 amount
    ) external virtual onlyOwner nonReentrant {
        require(
            tokenAddress.isContract(),
            "ERC1155 token address must be a contract"
        );

        IERC1155 tokenContract = IERC1155(tokenAddress);
        require(
            tokenContract.balanceOf(address(this), id) >= amount,
            "this contract doesn't own the amount of tokens to withdraw"
        );

        tokenContract.safeTransferFrom(
            address(this),
            _msgSender(),
            id,
            amount,
            ""
        );
    }

    event WithdrawERC1155(address tokenAddress, uint256 id, uint256 amount);
}

contract LinkedList is WithdrawableOwnable {
    uint256 public head;
    uint256 public tail;

    struct StakeInfos {
        address wallet;
        uint64 startedAt;
        uint64 endAt;
        uint128 tokensAmount;
    }

    mapping(uint256 => StakeInfos) public stakes;
    mapping(address => uint256) public stakesNumberPerWallet;
    uint256 public numberOfWalletsInStake;

    function next(uint256 _id) internal view virtual returns (bool, uint256) {
        for (uint256 i = _id; i > tail; i--) {
            if (stakes[i - 1].wallet != address(0)) return (true, i - 1);
        }
        return (false, 0);
    }

    function prev(uint256 _id) internal view virtual returns (bool, uint256) {
        for (uint256 i = _id; i < head; i++) {
            if (stakes[i + 1].wallet != address(0)) return (true, i + 1);
        }
        return (false, 0);
    }

    function findAll() internal view virtual returns (StakeInfos[] memory) {
        uint256 i = tail;
        uint256 count = 0;
        StakeInfos[] memory stakesInfos = new StakeInfos[](
            numberOfWalletsInStake
        );
        while (i <= head) {
            if (stakes[i].wallet != address(0)) {
                stakesInfos[count] = stakes[i];
                count += 1;
            }
            i += 1;
        }
        return (stakesInfos);
    }

    function findAllByWallet(address _wallet)
        internal
        view
        virtual
        returns (StakeInfos[] memory)
    {
        uint256 i = tail;
        uint256 count = 0;
        StakeInfos[] memory stakesInfos = new StakeInfos[](
            stakesNumberPerWallet[_wallet]
        );
        while (i <= head) {
            if (stakes[i].wallet == _wallet) {
                stakesInfos[count] = stakes[i];
                count += 1;
            }
            i += 1;
        }
        return (stakesInfos);
    }

    function addHead(
        address _wallet,
        uint64 _startedAt,
        uint64 _endAt,
        uint128 _tokensAmount
    ) internal virtual {
        stakes[head + 1] = StakeInfos(
            _wallet,
            _startedAt,
            _endAt,
            _tokensAmount
        );
        head = head + 1;
        numberOfWalletsInStake += 1;
        stakesNumberPerWallet[_wallet] += 1;
    }

    function remove(uint256 _id) internal virtual {
        if (_id == head) {
            (, head) = next(head);
        }
        if (_id == tail) {
            (, tail) = prev(tail);
        }
        numberOfWalletsInStake -= 1;
        stakesNumberPerWallet[stakes[_id].wallet] -= 1;
        delete stakes[_id];
    }
}

contract AstroCashStake is LinkedList {
    address public constant astroCashToken =
        0x1b24ebbEc03298576337B1805c733cD225C8a6BC;
    address public constant busdToken =
        0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public sellWallet = 0xE83Ff9E0Efda366B481baaBd64C999faC4b84e01;

    struct RewardInfos {
        uint128 tokensTotal;
        uint64 startMonthTime;
        uint64 endMonthTime;
    }

    uint256 public currentMonthIndex;
    mapping(uint256 => RewardInfos) public rewardsForMonth;

    mapping(address => uint256) public lastMonthWithdrawPerWallet;

    uint64 public minTimeOfStake = 31536000;
    uint128 public minAmountOfStake = 50 ether;

    bool public cancelAllStakes = false;

    bool public canStake = true;

    constructor() {
        head = 0;
        tail = 0;
        rewardsForMonth[1] = RewardInfos(
            2897700000000000000000,
            1659312000,
            1661990399
        );
        rewardsForMonth[2] = RewardInfos(
            2604980000000000000000,
            1661990400,
            1664582399
        );
        currentMonthIndex = 3;
    }

    // ------------------------------------------------ MAKE STAKE ----------------------
    // USER FAZER O STAKE
    function stake(uint128 tokens) public payable nonReentrant {
        require(canStake, "Stake is paused.");
        require(
            tokens >= minAmountOfStake,
            "Value lower than the minimum required."
        );

        IERC20 tokenContract = IERC20(astroCashToken);
        uint256 balance = tokenContract.balanceOf(msg.sender);
        require(tokens <= balance, "You don't have enough tokens.");
        require(
            tokenContract.transferFrom(msg.sender, address(this), tokens),
            "Fail on transfer tokens."
        );

        uint64 currentTime = uint64(block.timestamp);
        addHead(msg.sender, currentTime, currentTime + minTimeOfStake, tokens);

        emit Stake(
            msg.sender,
            tokens,
            currentTime,
            currentTime + minTimeOfStake
        );
    }

    // USER REENTRAR NO STAKE
    function reStake(uint256 stakeIndex) public nonReentrant onlyOwner {
        require(canStake, "Stake is paused.");
        StakeInfos memory stakeInfo = stakes[stakeIndex];
        require(stakeInfo.wallet != address(0), "Stake not available.");
        uint64 currentTime = uint64(block.timestamp);
        require(stakeInfo.endAt < currentTime, "Unfinished stake.");

        stakeInfo.startedAt = currentTime;
        stakeInfo.endAt = currentTime + minTimeOfStake;

        stakes[stakeIndex] = stakeInfo;

        emit Stake(
            stakeInfo.wallet,
            stakeInfo.tokensAmount,
            stakeInfo.startedAt,
            stakeInfo.endAt
        );
    }

    // CARLOS FAZER O STAKE
    function addToStake(address wallet, uint128 tokens)
        public
        payable
        nonReentrant
    {
        require(
            msg.sender == owner() || msg.sender == sellWallet,
            "Ownable: caller is not the owner"
        );
        require(
            tokens >= minAmountOfStake,
            "Value lower than the minimum required."
        );

        IERC20 tokenContract = IERC20(astroCashToken);
        uint256 balance = tokenContract.balanceOf(msg.sender);
        require(tokens <= balance, "You don't have enough tokens.");
        require(
            tokenContract.transferFrom(msg.sender, address(this), tokens),
            "Fail on transfer tokens."
        );

        uint64 currentTime = uint64(block.timestamp);
        addHead(wallet, currentTime, currentTime + minTimeOfStake, tokens);

        emit Stake(wallet, tokens, currentTime, currentTime + minTimeOfStake);
    }

    // ADICIONAR USER PERSONALIZADO
    function addCustomStake(
        address wallet,
        uint64 startedAt,
        uint64 endAt,
        uint128 tokens
    ) public payable nonReentrant onlyOwner {
        require(
            tokens >= minAmountOfStake,
            "Value lower than the minimum required."
        );

        IERC20 tokenContract = IERC20(astroCashToken);
        uint256 balance = tokenContract.balanceOf(msg.sender);
        require(tokens <= balance, "You don't have enough tokens.");
        require(
            tokenContract.transferFrom(msg.sender, address(this), tokens),
            "Fail on transfer tokens."
        );

        addHead(wallet, startedAt, endAt, tokens);

        emit Stake(wallet, tokens, startedAt, endAt);
    }

    // ALTERAR INFOS DE UM USER
    function updateStake(
        uint64 stakeIndex,
        address wallet,
        uint64 startedAt,
        uint64 endAt,
        uint128 tokens
    ) public payable nonReentrant onlyOwner {
        StakeInfos memory stakeInfo = StakeInfos(
            wallet,
            startedAt,
            endAt,
            tokens
        );
        stakes[stakeIndex] = stakeInfo;
    }

    // ALTERAR INFOS DE UM USER
    function updateLastMonthPerWallet(address wallet, uint256 newMonth)
        public
        payable
        nonReentrant
        onlyOwner
    {
        lastMonthWithdrawPerWallet[wallet] = newMonth;
    }

    // ------------------------------------------------ WITHDRAW ------------------------
    // USER SACAR TOKENS APOS 1 ANO
    function exitStake(uint256 stakeIndex)
        public
        payable
        nonReentrant
        onlyOwner
    {
        require(canStake || cancelAllStakes, "Stake is paused.");
        StakeInfos memory stakeInfos = stakes[stakeIndex];
        require(stakeInfos.wallet > address(0), "No stake for withdrawal.");
        uint64 nowDate = uint64(block.timestamp);
        require(
            nowDate > stakeInfos.endAt || cancelAllStakes,
            "Minimum time not met."
        );

        IERC20 tokenContract = IERC20(astroCashToken);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(
            stakeInfos.tokensAmount <= balance,
            "The contract don't have enough tokens."
        );
        require(
            tokenContract.transferFrom(
                address(this),
                stakeInfos.wallet,
                stakeInfos.tokensAmount
            ),
            "Fail on transfer tokens."
        );

        remove(stakeIndex);

        emit ExitStake(stakeInfos.wallet, stakeInfos.tokensAmount);
    }

    // ------------------------------------------------ INCOME --------------------------
    // DISTRIBUIR OS BUSD
    function distributeIncome(
        uint256 monthIndex,
        uint128 tokensTotal,
        uint64 startMonthTime,
        uint64 endMonthTime
    ) public payable nonReentrant onlyOwner {
        IERC20 tokenContract = IERC20(busdToken);
        uint256 balance = tokenContract.balanceOf(msg.sender);
        require(tokensTotal <= balance, "You don't have enough BUSD.");
        require(
            tokenContract.transferFrom(msg.sender, address(this), tokensTotal),
            "Fail on transfer BUSD."
        );

        if (currentMonthIndex < monthIndex) {
            currentMonthIndex = monthIndex;
        }
        rewardsForMonth[monthIndex] = RewardInfos(
            tokensTotal,
            startMonthTime,
            endMonthTime
        );

        emit DistributeIncome(
            tokensTotal,
            monthIndex,
            startMonthTime,
            endMonthTime
        );
    }

    // USER SACAR O RENDIMENTO
    function withdrawIncome(address wallet, uint256 tokensAmount)
        public
        payable
        nonReentrant
        onlyOwner
    {
        require(canStake, "Stake is paused.");
        require(stakesNumberPerWallet[wallet] > 0, "Without stakes.");
        uint256 currentMonth = currentMonthIndex;
        require(
            lastMonthWithdrawPerWallet[wallet] < currentMonth,
            "Already withdraw."
        );

        IERC20 tokenContract = IERC20(busdToken);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(
            tokensAmount <= balance,
            "The contract don't have enough tokens."
        );
        require(
            tokenContract.transferFrom(address(this), wallet, tokensAmount),
            "Fail on transfer tokens."
        );

        lastMonthWithdrawPerWallet[wallet] = currentMonth;

        emit WithdrawIncome(wallet, tokensAmount, currentMonth);
    }

    // ------------------------------------------------ GETS ----------------------------
    // PEGAR O TOTAL TOKENS
    function getAllStakes() public view returns (StakeInfos[] memory) {
        return findAll();
    }

    // PEGAR TODOS OS STAKES DE UM USER
    function getStakesByWallet(address wallet)
        public
        view
        returns (StakeInfos[] memory)
    {
        return findAllByWallet(wallet);
    }

    // PEGAR TODOS OS INCOME
    function getAllIncomesInfos(uint256 from, uint256 to)
        public
        view
        returns (RewardInfos[] memory)
    {
        uint256 end = to <= currentMonthIndex ? to : currentMonthIndex;
        uint256 start = from < end ? from : 1;
        RewardInfos[] memory listOfRewards = new RewardInfos[](end - start + 1);
        uint256 count;
        for (uint256 index = from; index <= end; index++) {
            listOfRewards[count] = rewardsForMonth[index];
            count += 1;
        }
        return listOfRewards;
    }

    // ------------------------------------------------ SETS ----------------------------
    // MUDAR TEMPO DE DURACAO DO STAKE
    function setMinimumStakeTime(uint64 newTime) public onlyOwner {
        require(newTime != minTimeOfStake, "Already set.");
        minTimeOfStake = newTime;
    }

    // PERMITIR SACAR ANTES DO TEMPO
    function setMinimumAmount(uint128 newValue) public onlyOwner {
        require(newValue != minAmountOfStake, "Already set.");
        minAmountOfStake = newValue;
    }

    // ALTERAR VALOR MINIMO
    function setCancelAllStake(bool newState) public onlyOwner {
        require(newState != cancelAllStakes, "Already set.");
        cancelAllStakes = newState;
    }

    // TRAVAR ENTRADA NO STAKE
    function setCanStake(bool newState) public onlyOwner {
        require(newState != canStake, "Already set.");
        canStake = newState;
    }

    // TROCAR WALLET DE VENDA
    function setCanStake(address newAddress) public onlyOwner {
        require(newAddress != sellWallet, "Already set.");
        sellWallet = newAddress;
    }

    // ------------------------------------------------ EVENTS --------------------------
    event Stake(
        address indexed owner,
        uint128 tokensAmount,
        uint64 startedAt,
        uint64 endAt
    );
    event ExitStake(address indexed owner, uint128 tokensAmount);
    event DistributeIncome(
        uint256 tokensAmount,
        uint256 month,
        uint256 monthStartAt,
        uint256 monthEndAt
    );
    event WithdrawIncome(
        address indexed owner,
        uint256 tokensAmount,
        uint256 month
    );
}