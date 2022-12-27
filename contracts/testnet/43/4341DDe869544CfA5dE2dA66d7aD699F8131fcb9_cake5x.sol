/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

pragma solidity 0.5.12;

/**
 * @title TRC20 interfac    e
 */
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


contract cake5x {
    using SafeMath for uint256;
    
    struct AddressDetail {
        uint256 planAIndex;
        address planAAddress;
    }

    struct Users {
        uint128 profit;
        uint24 index;
        uint8 count; // number of downline
        uint8 status; // 0:all false 1:activeA 2:activeB
        uint8 loop;
        uint8 self;
        uint8 tBCount;
        AddressDetail upline;
    }

    address private Owner;
    address private NoUp;
    address payable private Marketing_addr;
    address payable private Developer_addr;
    AddressDetail[] private planB;
    IBEP20 private token;
    uint128 private NumInvestor;
    uint128 private TotalInvestment;
    mapping(address => uint256) private withdrawn;
    mapping(uint256 => mapping(address => Users)) private investors;

    event isDeposit(address inInvestor, address upline);

    constructor(address _tokenAddress) public {
        Owner = msg.sender;
        NoUp = 0x64DA16a19deCf0D2658D159715b65c1a85C5227b;
        Marketing_addr = 0x6f1a329728634a9fef7fc9aFEB772ceE9721b990;
        Developer_addr = 0x01Eb6E3E3D6b7207Ab219619951e28A940124c10;
        token = IBEP20(_tokenAddress);
        investors[1][NoUp].status = 1;
        investors[0][NoUp].self = 1;
        planB.push(AddressDetail(0, 0x64DA16a19deCf0D2658D159715b65c1a85C5227b));
    }

    function invest(uint256 upline_index, address upline) external {
        uint256 length = investors[upline_index][upline].count;

        if (upline != NoUp)require(length < 5 && (investors[upline_index][upline].status > 0),"Invalid Upline address");
        require(token.balanceOf(msg.sender) >= 5*(10**18),"Insufficient balance");
        token.transferFrom(msg.sender, address(this), 5*(10**18));

        uint256 newindex;
        if (investors[0][msg.sender].status != 0) {
            newindex = investors[0][msg.sender].self + 1;
            investors[0][msg.sender].self++;
        }
        investors[newindex][msg.sender].upline = AddressDetail(upline_index,upline);
        investors[newindex][msg.sender].status = 1;
        investors[upline_index][upline].count++;
        NumInvestor++;
        TotalInvestment += 5*(10**18);
        investors[0][Marketing_addr].profit += 1/2*(10**18);
        investors[0][Developer_addr].profit += 1/2*(10**18);

        if (investors[upline_index][upline].count == 5 && upline != NoUp) {
            //upline start loop B
            updateB(upline_index, upline);
        } else {
            investors[upline_index][upline].profit += 4*(10**18);
        }
        emit isDeposit(msg.sender, upline);
    }

    function updateB(uint256 planAIndex, address upline) private {
        investors[planAIndex][upline].status = 2; //update status in plan A for the trigger address
        planB.push(AddressDetail(planAIndex, upline));

        uint mLength = planB.length-1;
        investors[planAIndex][upline].index = uint24(mLength); //update trigger address position in plan B

        uint tempIndex = planB[0].planAIndex;
        address tempPlanAAddr = planB[0].planAAddress;
        investors[tempIndex][tempPlanAAddr].tBCount++;

        uint bCount = investors[tempIndex][tempPlanAAddr].tBCount;

        if( bCount == 1){
            investors[tempIndex][tempPlanAAddr].profit += 4*(10**18);
        }else if( bCount == 2){
            for(uint i=0;i<mLength;i++){
                planB[i]=planB[i+1];
                investors[planB[i].planAIndex][planB[i].planAAddress].index--;
            }

            delete investors[tempIndex][tempPlanAAddr].tBCount;
            investors[0][tempPlanAAddr].loop++;
            investors[tempIndex][tempPlanAAddr].index = uint24(mLength);

            planB[mLength]=AddressDetail(tempIndex, tempPlanAAddr);

           investors[planB[0].planAIndex][planB[0].planAAddress].profit += 4*(10**18);
           investors[planB[0].planAIndex][planB[0].planAAddress].tBCount++;
        }
    }

    function getSelf(address _addr) external view returns (uint8 self) {
        return investors[0][_addr].self;
    }

    function investor(uint256 ind, address _addr)external view returns ( address upline,uint256 upline_index,uint128 profit,uint8 status,
        uint160 index, uint8 loop,uint8 self,uint256 counts){

        Users storage users = investors[ind][_addr];
        upline_index = users.upline.planAIndex;
        upline = users.upline.planAAddress;
        self = users.self;
        profit = users.profit;
        status = users.status;
        index = users.index;
        loop = users.loop;
        counts = users.count;
        return (upline, upline_index, profit, status, index, loop, self, counts);
    }
    
    function withdraw(uint256 amount) external {
        uint256 TA = withdrawable(msg.sender);
        require(amount <= TA, "insufficient balance");
        withdrawn[msg.sender] = withdrawn[msg.sender].add(amount);
        token.transfer(msg.sender, amount);
    }

    function PlanB(uint256 ind) external view returns (uint256 index, address addr) {
        return (planB[ind].planAIndex, planB[ind].planAAddress);
    }

    function PlanBLength() external view returns (uint256 length) {
        return planB.length;
    }

    function getInvestD() external view returns (uint128 numInvestor, uint128 totalInvestment) {
        return (NumInvestor, TotalInvestment);
    }

    function withdrawable(address _addr) public view returns (uint256 _amount) {
        uint256 length = investors[0][_addr].self;
        _amount = 0;

        for (uint256 i = 0; i <= length; i++) {
            _amount = _amount.add(investors[i][_addr].profit);
        }

        _amount = _amount.sub(withdrawn[_addr]);

        return _amount;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}