// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*
本程序中包括多个合约，其中最后一个iPandaTeam为发布的主合约。
所有其它合约均被引用在iPandaTeam主合约中。
默认筹集资金和分红均使用BUSD。
*/

import "./onlyAdmin.sol";
import "./iPandaERC20interface.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


/*
本合约主要功能：
设置并维护whiteList --只有white List中的用户可以参与决策
1、检查地址是否是iPanda member
2、添加iPanda新成员
3、删除iPanda成员
4、memberOnly modifier
*/
contract iPandaWhiteList is onlyAdmin {

    //以下两项同时满足才是iPanda的team成员。如果要删除某成员，则将其地址设置为false;
    address[] whiteList; //存放所有iPanda team成员address
    
    mapping (address => bool) member;  //确定某个address是否为whiteList的teamMember；

    modifier memberOnly() {
        require(member[msg.sender], 'Not iPanda Member');
        _;
    }

    //check an address is a member of iPanda team or not
    function checkMember(address _addr) public view returns (bool) {
        return member[_addr];
    }

    // add new member to iPanda team
    function addMember(address _member) public adminOnly {

        bool isIn = false;

        //首先检查地址是否在whiteList数组中
        for (uint i=0; i < whiteList.length; i++) {
            if (whiteList[i] == _member) {
                isIn = true;
                break;
            }
        }
        //如果不在whiteList数组中，则在数组尾部填加
        if (!isIn) {
            whiteList.push(_member);
        }

        member[_member] = true;
    }

    function getWhiteList() public view returns (address[] memory) {
        return whiteList;
    }

    //delete a member from iPanda team
    function delMember(address _member) public adminOnly {
        member[_member] = false;
    }
}

/*
本合约核心功能：
1、最初始申购iPanda
    - members invest busd or cancel invested.
2、根据申购情况，计算iPanda释放数量并mint对应的iPanda
    -管理员发起finish，合约根据投入情况，计算每个投资者获得的iPanda数量，并锁仓
*/
contract iPandaInitial is iPandaWhiteList {


    struct Init {
        uint8 initId;
        uint initialTotalAmount; // the actual invest total amount of BUSD
        uint startBlock; //锁仓的开始区块
        bool initialFinished; // will be true after finished the initial invest.
        uint price; //The price for initial per $iPanda. /10^5
        uint limitPerAddress; // The Max limit of invest BUSD  for every Account.
        uint totalLimit; // The total limit BUSD for the init.

        //iPanda team成员首次申购后，每个成员获得的iPanda数量，默认全部锁仓
        mapping (address => uint) iPandaForInitialMember;

        //iPanda team成员已领取过的iPanda数量
        mapping (address => uint) iPandaClaimed;

        //iPanda team成员投资金额
        mapping (address => uint) investAmount;
    }

    uint8 initCount;
    mapping (uint8 => Init) init;

    iPandaERC20interface initialToken; // The token address pay on initial  ( BUSD )
    iPandaERC20interface iPandaERC20; // iPandaAddress
    iPandaERC20interface pandaERC20; // iPandaAddress


    //部署合约时执行
    function __iPandaInitial_init_() public initializer {
        initCount = 0;
    }

    // only people who is in whiteList can invest
    function invest(uint8 _initId,uint _amount) public memberOnly {
        require(init[_initId].initId == _initId, "Initial Not Set");
        require(!init[_initId].initialFinished, "initialFinished");
        require(init[_initId].investAmount[msg.sender] + _amount <= init[_initId].limitPerAddress, "Max Limit reached.");
        require(init[_initId].initialTotalAmount + _amount <= init[_initId].totalLimit, 'Max Limit reached.');
        initialToken.transferFrom(msg.sender,address(this),_amount);
        init[_initId].initialTotalAmount += _amount;
        init[_initId].investAmount[msg.sender] += _amount;
    }

    function cancelInvest(uint8 _initId,uint _amount) public memberOnly {
        require(!init[_initId].initialFinished, "initialFinished");
        require(init[_initId].investAmount[msg.sender] >= _amount, "invested not enough");
        init[_initId].initialTotalAmount -= _amount;
        init[_initId].investAmount[msg.sender] -= _amount;
        initialToken.transfer(msg.sender, _amount);
    }

    //check the iPanda initial amount of a investor
    function getInvestorIPanda(uint8 _initId,address _addr) public view returns (uint) {
        return init[_initId].iPandaForInitialMember[_addr];
    }

    //check the busd initial amount of a investor
    function getInvestedAmount(uint8 _initId, address _addr) public view returns (uint) {
        return init[_initId].investAmount[_addr];
    }

    //check the initialTotalAmount
    function getInitialTotalAmount(uint8 _initId) public view returns (uint) {
        return init[_initId].initialTotalAmount;
    }

    //管理员设置两个token，1个是BUSD，1个是iPanda
    function setToken(
            iPandaERC20interface _initialToken, 
            iPandaERC20interface _iPandaERC20, 
            iPandaERC20interface _pandaERC20
        ) public adminOnly {
            initialToken = _initialToken;
            iPandaERC20 = _iPandaERC20;
            pandaERC20 = _pandaERC20;
    }

    //admin to finish the invest and calculate the iPanda amount for everyone of whiteList.
    function finishInvest(uint8 _initId) public adminOnly {
        require(!init[_initId].initialFinished, "initialFinished");
        init[_initId].initialFinished = true;
        init[_initId].startBlock = block.number;
        for (uint8 i = 0; i < whiteList.length; i++) {
            address _m = whiteList[i];
            init[_initId].iPandaForInitialMember[_m] = init[_initId].investAmount[_m] / init[_initId].price * 10**5;
        }
    }

    function setInit(uint8 _initId, uint _initialTotalAmount, uint _price, uint _limitPerAddress, uint _totalLimit) public adminOnly {
        require(init[_initId].initId == 0, "Init exist");
        initCount = _initId;
        init[_initId].initId = _initId;
        init[_initId].initialTotalAmount = _initialTotalAmount; // the actual invest total amount of BUSD
        init[_initId].price = _price;
        init[_initId].totalLimit = _totalLimit;
        init[_initId].limitPerAddress = _limitPerAddress;
        init[_initId].initialFinished = false; // will be true after finished the initial invest.
    }

    function getInit(uint8 _initId) public view returns (uint8, uint, uint, bool) {

        return (
            init[_initId].initId,
            init[_initId].initialTotalAmount, 
            init[_initId].price,
            init[_initId].initialFinished
            );
    }

    //check the iPanda amount of claimed for someone.
    function getClaimed(uint8 _initId, address _addr) public view returns (uint) {
        return init[_initId].iPandaClaimed[_addr];
    }

    function _claim(uint8 _initId, uint _amount) private memberOnly {
        
        require(init[_initId].iPandaForInitialMember[msg.sender] >= init[_initId].iPandaClaimed[msg.sender] + _amount, "Unclaimed not enough");
        init[_initId].iPandaClaimed[msg.sender] += _amount;
        iPandaERC20.mint(msg.sender, _amount);

    }

    //将所有可claim的iPanda数量进行claim
    function claim(uint8 _initId) public memberOnly {

        uint claimRatio = calculateReleaseRatio(_initId); //获取当前释放比例, /10^10

        //根据释放比例，扣除之前已经claimed的数量，得出当前可以claim的数量
        uint amountToClaim = init[_initId].iPandaForInitialMember[msg.sender] * claimRatio / 10**10 - init[_initId].iPandaClaimed[msg.sender]; 

        require(amountToClaim > 0, "Nothing to Claim");
        _claim(_initId, amountToClaim);
        }

    function claimAll() public memberOnly {

        for (uint8 i=0; i < initCount; i++) {

            uint claimRatio = calculateReleaseRatio(i+1); //获取当前释放比例, /10^10

            //根据释放比例，扣除之前已经claimed的数量，得出当前可以claim的数量
            uint amountToClaim = init[i+1].iPandaForInitialMember[msg.sender] * claimRatio / 10**10 - init[i+1].iPandaClaimed[msg.sender]; 

            if(amountToClaim > 0) {
                _claim(i+1, amountToClaim);
            }
        }
    }


    //计算一个账户，在各轮IDO中未claimed的iPanda总和
    function calculateAmountUnclaimed(address _addr) public view returns (uint) {
        uint totalUnclaimed = 0;
        for (uint8 i=0; i < initCount; i++) {
            totalUnclaimed += init[i+1].iPandaForInitialMember[_addr] - init[i+1].iPandaClaimed[_addr];
        }
        return totalUnclaimed;
    }

    function _calculateTotalUnclaimed() internal view returns (uint) {

        uint _totalUnclaimed = 0;

        for (uint i=0; i<whiteList.length; i++ ) {
            _totalUnclaimed += calculateAmountUnclaimed(whiteList[i]);
        }

        return _totalUnclaimed;
    }

    //计算iPanda的释放比例。每年按365天计算，总区块10512000. 为防止出现小数，比例多乘以10^10，在使用时记得/10^10。
    function calculateReleaseRatio(uint8 _initId) public view returns (uint) {

        uint startBlock = init[_initId].startBlock;

        if (block.number < startBlock + 2592000) {
            //未达到90天，释放率为0
            return 0;
        } else if (block.number < startBlock + 2592000 + 10512000) {
            //达到90天后，一年内释放40%，按区块计算
            //为防止产生小数，将实际比例多乘以10的10次方，在使用是要除掉。
            return ((block.number - startBlock - 2592000) * 10**10 /10512000 * 40/100);  
        } else if (block.number < startBlock + 2592000 + 10512000 * 2) {
            //第二年释放30%，按区块计算
            //计算出第二年应拿的比例，加上第一年的40%得出总比例。为防止产生小数，将实际比例多乘以10的10次方，在使用是要除掉。
            return ((block.number - startBlock - 2592000 - 10512000) * 10**10 / 10512000 * 30/100 + 40 * 10**10 / 100);
        } else if (block.number < startBlock + 2592000 + 10512000 * 3) {
            //第三年释放15%，按区块计算
            //计算出第三年应拿的比例，加上前两年的70%得出总比例。为防止产生小数，将实际比例多乘以10的10次方，在使用是要除掉。
            return ((block.number - startBlock - 2592000 - 10512000 * 2) * 10**10 /10512000 * 15/100 + 70 * 10**10 / 100);  
        } else if (block.number < startBlock + 2592000 + 10512000 * 4) {
            //第四年释放10%，按区块计算
            //计算出第四年应拿的比例，加上前三年的85%得出总比例。为防止产生小数，将实际比例多乘以10的10次方，在使用是要除掉。
            return ((block.number - startBlock - 2592000 - 10512000 * 3) * 10**10 /10512000 * 10/100 + 85 * 10**10 / 100);  
        } else if (block.number < startBlock + 2592000 + 10512000 * 5) {
            //第五年释放5%，按区块计算
            //计算出第五年应拿的比例，加上前四年的95%得出总比例。为防止产生小数，将实际比例多乘以10的10次方，在使用是要除掉。
            return ((block.number - startBlock - 2592000 - 10512000 * 4) * 10**10 /10512000 * 5/100 + 95 * 10**10 / 100);
        } else if (block.number > startBlock + 2592000 + 10512000 * 5) {
            //超过五年，返回100%。 多乘以10**10，使用时除掉
            return 10**10;
        } else {
            return 0;
        }
    }
}

/*
本合约核心功能：
1、管理员创建投票
2、对于white list进行投票并统计结果
3、根据投票结果进行支付
*/
contract iPandaVote is iPandaInitial {

    //每一个投票数量信息的存储
    struct Vote {
        uint id;
        uint startBlock;
        uint endBlock;
        uint totalBalance;  // 所有whiteList的balance总和，如果white List所有成员全部投票完成的话，所有票数加起来应该正好等于total balance
        uint8 optionNumber; // 本proposal中，option总个数。如果是审批类投票，1表示approve，2表示reject
        mapping (uint8 => uint) option; // 每个option的总票数
        mapping (address => uint8) voter; //每个投票者投了哪个选项
    }

    mapping (uint => Vote) proposals;

    // 管理员新建立proposal
    function setProposal(uint _id, uint _startBlock, uint _endBlock, uint8 _optionNumber) public adminOnly {
        require(_id != proposals[_id].id, "Proposal has set");
        proposals[_id].id = _id;
        proposals[_id].startBlock = _startBlock;
        proposals[_id].endBlock = _endBlock;
        proposals[_id].optionNumber = _optionNumber;
    }

    // team member vote for a proposal. _id is the proposal# id
    function vote(uint _id, uint8 _option) public memberOnly {
        require(_id == proposals[_id].id, "The Proposal has not set");
        require(block.number >= proposals[_id].startBlock, "The Proposal has not started yet");
        require(block.number < proposals[_id].endBlock, "The Proposal has ended");
        require(_option != 0 && _option <= proposals[_id].optionNumber, "Wrong optionNumber");
        proposals[_id].voter[msg.sender] = _option;
        _updateVote(_id);
    }

    //根据当前每个whiteList account的balance + unclaim总数，进行投票结果统计
    function _updateVote(uint _id) private {

        uint _totalBalance;
        uint[] memory _option = new uint[](proposals[_id].optionNumber+1);

        for(uint i=0; i < whiteList.length; i++) {
            address v = whiteList[i];
            uint8 o = proposals[_id].voter[v];
            uint _balance = iPandaERC20.balanceOf(v) + calculateAmountUnclaimed(v);
            _totalBalance += _balance;
            _option[o] += _balance;
        }

        proposals[_id].totalBalance = _totalBalance;

        for(uint8 j=0; j<= proposals[_id].optionNumber; j++) {
            proposals[_id].option[j] = _option[j];
        }
    }
}

/*
本合约核心功能：
1、质押iPanda等待分红
2、基于投票结果并根据持仓数量进行分红（合并计算未claim的iPanda）
注：分红是分BUSD
*/

contract iPandaBonus is iPandaInitial {

    uint iPandaTotalStaked; // 计算stake的总和；
    uint bonusPerIPanda; //每个iPanda可领取的Bonus数量;
    mapping (address => uint) iPandaStaked; // 记录每个address的质押数量；
    mapping (address => uint) iPandaDebt; // 质押前的分红数量
    mapping (uint => uint) bonusAmount; //每次分红时，BUSD的数量，第一个uint是投票proposal id， 每二个uint是要分红的busd数量

    //质押分红
    function bonusStake() public {
        uint _balance = iPandaERC20.balanceOf(msg.sender);
        require(_balance > 0, "No iPanda Balance");
        iPandaERC20.transferFrom(msg.sender, address(this), _balance);
        iPandaTotalStaked += _balance;
        iPandaStaked[msg.sender] += _balance;
        iPandaDebt[msg.sender] = bonusPerIPanda;
    }

    //把分红提取到钱包
    function bonusClaim() public {
        uint _bonus = calculateBonus(msg.sender);
        require(_bonus > 0, "No bonus to claim");
        iPandaDebt[msg.sender] = bonusPerIPanda;
        initialToken.transfer(msg.sender, _bonus);
    }

    //赎回iPanda质押，赎回后不再享受分红
    function bonusWithdraw() public {
        uint _amount = iPandaStaked[msg.sender];
        require(_amount > 0, "Nothing to withdraw");

        // If bonus > 0, claim the bonus at first.
        if (calculateBonus(msg.sender) >0) {
            bonusClaim();
        }

        iPandaStaked[msg.sender] = 0;
        iPandaTotalStaked -= _amount;
        iPandaERC20.transfer(msg.sender, iPandaStaked[msg.sender]);
    }

    //计算某个地址当前的分红
    function calculateBonus(address _addr) public view returns (uint) {
        
        return ((bonusPerIPanda - iPandaDebt[_addr]) * (iPandaStaked[_addr] + calculateAmountUnclaimed(_addr)) / 10**18);         

    }

    function _setBonus(uint _amount) internal {

        bonusPerIPanda += _amount * 10**18 / (_calculateTotalUnclaimed() + iPandaTotalStaked); // 为防止小数，所以多乘以10^18，使用时除掉。

    }

}


/*
--------------本合约为iPanda主合约---------------
本合约核心功能：
1、计算iPanda持仓数量
2、基于投票支付相关费用
3、基于投票分红
3、将iPanda转换为Panda
*/
contract iPandaTeam is iPandaVote,iPandaBonus {

    struct PayInfo {
        uint id;
        address to;
        iPandaERC20interface token;
        uint amount;
    }

    mapping (uint => PayInfo) payInfo;

    uint8 iPanda2PandaRatio; //1个iPanda可以兑换多少Panda，默认设置为100；

    function initialize() public initializer {
        __admin_init_();
        __iPandaInitial_init_();
        iPanda2PandaRatio = 100;
    }

    //exchange iPanda to Panda by Ratio, default is 100;
    function iPanda2Panda(uint _amount) public {
        require(iPandaERC20.balanceOf(msg.sender) >= _amount, "iPanda Balance is not enough");
        iPandaERC20.burn(msg.sender, _amount);
        pandaERC20.mint(msg.sender, _amount * iPanda2PandaRatio);
    }

    // 管理员发起支付申请投票
    function setVoteForPay(iPandaERC20interface _token, address _to, uint _amount, uint _proposalId) public adminOnly {
        require(_token.balanceOf(address(this)) >= _amount, "Balance is not enough");

        // 支付申请的投票，只设置2个投票选项。 1表示approve，2表示reject。
        //endBlock象征性设定为block.number * 2,当投票赞同数达到66.7%时，自动设定endBlock
        setProposal(_proposalId, block.number, block.number * 2, 2); 

        payInfo[_proposalId] = PayInfo(_proposalId, _to, _token, _amount);
    }

    // member进行支付投票,投票后自动统计票数并判断当前approve是否超过66.7%，超过自动付款
    function voteForPay(uint _proposalId, uint8 _option) public memberOnly {
        require(_proposalId == payInfo[_proposalId].id, "VotePay is not set");
        vote(_proposalId, _option);
        if (proposals[_proposalId].option[1] > proposals[_proposalId].totalBalance * 667 / 1000) {
            payInfo[_proposalId].token.transfer(payInfo[_proposalId].to, payInfo[_proposalId].amount);
            proposals[_proposalId].endBlock = block.number;
        }
    }
    
    // 管理员发起分红申请投票
    function setVoteForBunus(uint _amount, uint _proposalId) public adminOnly {
        require(initialToken.balanceOf(address(this)) >= _amount, "Balance not enough");

        // 分红申请的投票，只设置2个投票选项。 1表示approve，2表示reject。
        //endBlock象征性设定为block.number * 2,当投票赞同数达到66.7%时，自动设定endBlock
        setProposal(_proposalId, block.number, block.number * 2, 2); 
        bonusAmount[_proposalId] = _amount;

    }

    // member进行支付投票,投票后自动统计票数并判断当前approve是否超过66.7%，超过自动分红
    function voteForBonus(uint _proposalId, uint8 _option) public memberOnly {
        require(_proposalId == payInfo[_proposalId].id, "VoteBonus is not set");
        vote(_proposalId, _option);
        if (proposals[_proposalId].option[1] > proposals[_proposalId].totalBalance * 667 / 1000) {
            _setBonus(bonusAmount[_proposalId]);
            proposals[_proposalId].endBlock = block.number;
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";



contract onlyAdmin is Initializable {

    address admin;

    function __admin_init_() internal initializer {
        admin = msg.sender;
    }

    modifier adminOnly {
        require(msg.sender == admin, "adminOnly");
        _;
    }

    function setAdmin(address _admin) public adminOnly {
        admin = _admin;
    }

    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface iPandaERC20interface {

    event mintEvent(address _to, address _controller, uint _amount);
    event burnEvent(address _from, uint _amount);

    function mint(address _to, uint _amount) external;
    function burn(address _from, uint _amount) external;
    function controllerInfo(address _controller) external view returns (uint);
    function getMaxMintable() external view returns (uint);

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
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

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
library StorageSlot {
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
// OpenZeppelin Contracts v4.4.1 (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967Proxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/transparent/ProxyAdmin.sol)

pragma solidity ^0.8.0;

import "./TransparentUpgradeableProxy.sol";
import "../../access/Ownable.sol";

/**
 * @dev This is an auxiliary contract meant to be assigned as the admin of a {TransparentUpgradeableProxy}. For an
 * explanation of why you would want to use this see the documentation for {TransparentUpgradeableProxy}.
 */
contract ProxyAdmin is Ownable {
    /**
     * @dev Returns the current implementation of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Returns the current admin of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Changes the admin of `proxy` to `newAdmin`.
     *
     * Requirements:
     *
     * - This contract must be the current admin of `proxy`.
     */
    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrades `proxy` to `implementation`. See {TransparentUpgradeableProxy-upgradeTo}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {
        proxy.upgradeTo(implementation);
    }

    /**
     * @dev Upgrades `proxy` to `implementation` and calls a function on the new implementation. See
     * {TransparentUpgradeableProxy-upgradeToAndCall}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgradeAndCall(
        TransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
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
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
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
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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