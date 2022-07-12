/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
library SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b, "Multiply must be safe!");
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Divisor cannot be 0!");
        uint256 c = a / b;
        require(a == b * c + (a % b), "Divide must be safe!");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Sub must be safe!");
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a && c >= b, "Add must be safe!");
        return c;
    }
}

/*
 * BaseContract Class with lockAll and transferOwnership functions
 */
contract BaseContract {
    address public owner; // owner account
    bool public lockAll = false; // lock all functions in the contract

    /* Only owner can call function, like admin functions */
    modifier onlyOwner() {
        if (msg.sender != owner)
            revert("This function must be called by owner!");
        _;
    }

    /* The function can be called only on unlocked status */
    modifier notLocked() {
        require(!lockAll, "Contract had locked!");
        _;
    }

    /* The function can be called only on locked status */
    modifier Locked() {
        require(lockAll, "Contract had not locked!");
        _;
    }

    /* Check account address is not zero */
    modifier checkAccount(address _to) {
        // Prevent account to 0x0 address.
        require(
            _to != address(0x0),
            "The destination account is zero address!"
        );
        _;
    }

    /* Fire event when ownership has transferred */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /* Initializes contract */

    /* Transfer ownership to other account, only owner can do it and contract is on unlocked status */
    function transferOwnership(address newOwner)
        public
        notLocked
        onlyOwner
        checkAccount(newOwner)
        returns (bool)
    {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }

    /* Check Function */
    function test() public pure returns (bool) {
        return true;
    }
}
interface IAlgorithmContract {
    //borrow start
    /* 用户借款 Borrowed USDA = 存入抵押品数量 Collateral Amount * 抵押率 Collateral Ratio *  抵押品价格 Collateral Price */
    function calBorrowedUSDA(
        uint256 _collateral_amount,
        uint256 _collateral_ratio,
        uint256 _collateral_price
    ) external view returns (uint256);

    /* 用户实际收到的USDA Acquired USDA = 存入抵押品数量 Collateral Amount * 抵押率 Collateral Ratio * （1 - 借款费 Borrow Fee）*  抵押品价格 Collateral Price */
    function calAcquiredUSDA(
        uint256 _collateral_amount,
        uint256 _collateral_ratio,
        uint256 _borrow_fee,
        uint256 _collateral_price
    ) external view returns (uint256);

    /* 借款费用: Borrow Fee Archimedes 收到的 = 存入抵押品数量 Collateral Amount * 抵押率 Collateral Ratio * 借款费 Borrow Fee*  抵押品价格 Collateral Price */
    function calBorrowFeeArchimedes(
        uint256 _collateral_amount,
        uint256 _collateral_ratio,
        uint256 _borrow_fee,
        uint256 _collateral_price
    ) external view returns (uint256);

    /* 用户输入：借贷量所占抵押品的比例。此比例不可以超过 MCR（Normal Mode） 或者 Max VCR（Recovery Mode） */
    // function checkCollateralRatio(uint256 _rates) external view returns (bool);

    /* 预期清算价格 Expected Liquidation Price = 抵押品价格 Collateral Price * 抵押率 Collateral Ratio / 清算比率 Liquidation Ratio */
    function calExpectedLiquidationPrice(
        uint256 _collateral_price,
        uint256 _collateral_ratio,
        uint256 _liquidation_ratio
    ) external view returns (uint256);

    /* 头寸健康度 Health Rate = (抵押品价格 Collateral Price - 清算价格 Liquidation Price) / 抵押品价格Collateral Price */
    function calHealthRate(uint256 _collateral_price_revised,uint256 _liquidation_price,uint256 _collateral_price) external view returns (uint256);

    //borrow end
    //repay start
    //全部还款
    //实际借出USDA数量 Effective Borrowed
    function calEffectiveBorrowed() external view returns (uint256);

    //利息 Interest = 实际借出USDA金额 Effective Borrowed * 利率 APR * 借贷天数 / 365.25 （考虑闰年，一年按照 365.25 天数计算）
    function calInterest(
        uint256 _effective_borrowed,
        uint256 _APR,
        uint256 _borrow_day
    ) external view returns (uint256);

    //偿还usda总量 Total Amount = 初始借款 Borrowed + 利息 Interest
    function calRepayUsdaTotalAmount(
        uint256 _init_borrowed_amount,
        uint256 _interest
    ) external view returns (uint256);

    //销毁USDA数量 USDA Burned =  偿还USDA数量 USDA Repaid

    //部分还款
    //还款金额 Repay USDA = （提现抵押品数量 Withdraw Collateral Amount * Collateral Price 抵押品价格） /  提现比例 Withdraw Ratio
    /*
        说明：用户输入+计算结果。数值 ≤ 实际存入抵押品数量 Effective Collateral Amount
        如果调整上方的还款金额，则公式：
        提现抵押品数量 Withdraw Collateral Amount= （用户还款 Repay USDA * 提现比例 Withdraw Ratio ）/ Collateral Price 抵押品价格
     */
    function calRepayUsda(
        uint256 _withdraw_collateral_amount,
        uint256 _collateral_price,
        uint256 _withdraw_ratio
    ) external view returns (uint256);

    //提现抵押品数量 Withdraw Collateral Amount= （用户还款 Repay USDA * 提现比例 Withdraw Ratio ）/ Collateral Price 抵押品价格
    function calWithdrawCollateralAmount(
        uint256 _repay_usda,
        uint256 _withdraw_ratio,
        uint256 _collateral_price
    ) external view returns (uint256);

    //偿还后剩余借款 Borrowed USDA After Repay = 实际借出USDA数量 Effective Borrowed * （1 - 偿还比例 Repay Ratio）
    function calBorrowedUSDAAfterRepay(
        uint256 _effective_borrowed,
        uint256 _repay_ratio
    ) external view returns (uint256);

    //预期剩余抵押品 Expected Collateral After Withdraw = 实际存入抵押品数量 Effective Collateral Amount - 提现抵押品数量 Collateral Withdraw Amount
    function calExpectedCollateralAfterWithdraw(
        uint256 _effective_collateral_amount,
        uint256 _collateral_withdraw_amount
    ) external view returns (uint256);

    //预期清算价格 Expected Liquidation Price = 抵押品价格 Collateral Price *  [ 偿还后剩余借款 Borrowed USDA After Repay / (预期剩余抵押品 Expected Collateral After Withdraw * 抵押品价格 Collateral Price * 清算比率 Liquidation Ratio）]
    function calRepayExpectedLiquidationPrice(
        uint256 _collateral_price,
        uint256 _borrowed_usda_after_repay,
        uint256 _expected_collateral_after_withdraw,
        uint256 _liquidation_ratio
    ) external view returns (uint256);

    //提现 start
    /*
    公式：  Max Withdrawable Ratio = 1 - （实际借款 Effective Borrowed + 截止当前产生的利息 Interest）/ （最大抵押率 MCR * 实际抵押品数量 Effective Collateral Amount * 抵押品价格 Collateral Price）
    */
    function maxWithdrawableRatio(
        uint256 _effective_borrowed,
        uint256 _interest,
        uint256 _MCR,
        uint256 _effective_collateral_amount,
        uint256 _collateral_price
    ) external view returns (uint256);

    /*
    公式：预期清算价格 Expected Liquidation Price = 抵押品价格 Collateral Price * [ (实际借款 Effective Borrowed + 截止当前产生的利息 Interest) / （预期剩下的抵押品价值 Expected Collateral After Withdraw * 清算比率 Liquidation Ratio）]
     */
    function withdrawablExpectedLiquidationPrice(
        uint256 _collateral_price,
        uint256 _effective_borrowed,
        uint256 _interest,
        uint256 _expected_collateral_after_withdraw,
        uint256 _liquidation_ratio
    ) external view returns (uint256);

    /*
    用户选择可提取抵押品的数量，不超过 Collateral Amount=最大值是 最大可提取抵押品比例 Maximum Withdrawable Ratio * 存入抵押品数量 Collateral Amount
     */
    function withdrawCollateralAmount(
        uint256 _maximum_withdrawable_ratio,
        uint256 _collateral_amount
    ) external view returns (uint256);

    //提现end

    //my position start
    /*Effective Liquidation Price：我的头寸目前的清算价格
    说明：计算结果。
    公式：实际清算价格 Effective Liquidation Price = 抵押品价格 Collateral Price * [ (实际借款 Effective Borrowed + 截止当前产生的利息 Interest) / (实际抵押品总价值 Effective Collateral Amount * 抵押品价格 Collateral Price * 清算比率 Liquidation Ratio)]
    */
    function myEffectiveLiquidationPrice(
        uint256 _collateral_price,
        uint256 _effective_borrowed,
        uint256 _interest,
        uint256 _collateral_amount,
        uint256 _liquidation_ratio
    ) external view returns (uint256);
    /*
    USDA Left To Borrow：我的头寸在 MCR 的范围内，还可以借贷多少 USDA。
    说明：计算结果。
    公式：剩余可借贷 USDA Left To Borrow = 实际抵押品数量 Effective Collateral Amount * 抵押品价格 Collateral Price * 最大质押率 MCR - 已借出金额 USDA Borrowed - 截至当前的利息 Interest
    */
    function myUSDALeftToBorrow(
        uint256 _collateral_amount,
        uint256 _collateral_price,
        uint256 _MCR,
        uint256 _effective_borrowed,
        uint256 _interest
    ) external view returns (uint256);



    //my position end
}   
contract AlgorithmContract is BaseContract, IAlgorithmContract {
    using SafeMath for uint256;
    uint256 constant PERCENT = 10000; // 为避免出现小数，100% == 10000
    uint256 constant decimal = 100000000; //小数位为8位
    //borrow start
    /* 用户借款 Borrowed USDA = 存入抵押品数量 Collateral Amount * 抵押率 Collateral Ratio *  抵押品价格 Collateral Price */
    function calBorrowedUSDA(
        uint256 _collateral_amount,
        uint256 _collateral_ratio,
        uint256 _collateral_price
    ) public override view returns (uint256) {
        uint256 amount = _collateral_amount;
        amount = amount.safeMul(_collateral_ratio);
        amount = amount.safeMul(_collateral_price);
        uint256 usda_amount = amount.safeDiv(PERCENT);
        return usda_amount;
    }

    /* 用户实际收到的USDA Acquired USDA = 存入抵押品数量 Collateral Amount * 抵押率 Collateral Ratio * （1 - 借款费 Borrow Fee）*  抵押品价格 Collateral Price */
    function calAcquiredUSDA(
        uint256 _collateral_amount,
        uint256 _collateral_ratio,
        uint256 _borrow_fee,
        uint256 _collateral_price
    ) public override view returns (uint256) {
        uint256 amount = _collateral_amount;
        amount = amount.safeMul(_collateral_ratio);
        amount = amount.safeMul(_collateral_price);
        amount = amount.safeDiv(PERCENT);
        //（1 - 借款费 Borrow Fee）
        uint256 usda_amount = amount.safeMul(PERCENT - _borrow_fee).safeDiv(
            PERCENT
        );
        return usda_amount;
    }

    /* 借款费用: Borrow Fee Archimedes 收到的 = 存入抵押品数量 Collateral Amount * 抵押率 Collateral Ratio * 借款费 Borrow Fee*  抵押品价格 Collateral Price */
    function calBorrowFeeArchimedes(
        uint256 _collateral_amount,
        uint256 _collateral_ratio,
        uint256 _borrow_fee,
        uint256 _collateral_price
    ) public override view returns (uint256) {
        uint256 amount = _collateral_amount;
        amount = amount.safeMul(_collateral_ratio);
        amount = amount.safeMul(_collateral_price);
        amount = amount.safeDiv(PERCENT);
        uint256 price = amount.safeMul(_borrow_fee).safeDiv(PERCENT);
        return price;
    }

    /* 预期清算价格 Expected Liquidation Price = 抵押品价格 Collateral Price * 抵押率 Collateral Ratio / 清算比率 Liquidation Ratio */
    function calExpectedLiquidationPrice(
        uint256 _collateral_price,
        uint256 _collateral_ratio,
        uint256 _liquidation_ratio
    ) public override view returns (uint256) {
        uint256 amount = _collateral_price.safeMul(decimal);
        amount = amount.safeMul(_collateral_ratio);
        amount = amount.safeDiv(PERCENT);
        uint256 price = amount.safeMul(PERCENT).safeDiv(_liquidation_ratio);
        return price;
    }

    /* 头寸健康度 Health Rate = (抵押品价格 Collateral Price - 清算价格 Liquidation Price) / 抵押品价格Collateral Price */
    function calHealthRate(uint256 _collateral_price_revised,uint256 _liquidation_price,uint256 _collateral_price) public override view returns (uint256) {
        uint256 rate = _collateral_price_revised.safeSub(_liquidation_price);
        rate = rate.safeDiv(_collateral_price);
        return rate;
    }

    //borrow end
    //repay start
    function calEffectiveBorrowed() public override view returns (uint256) {
        return 1;
    }

    //利息 Interest = 实际借出USDA金额 Effective Borrowed * 利率 APR * 借贷天数 / 365.25 （考虑闰年，一年按照 365.25 天数计算）
    function calInterest(
        uint256 _effective_borrowed,
        uint256 _APR,
        uint256 _borrow_day
    ) public override view returns (uint256) {
        uint256 interest = _effective_borrowed.safeMul(_APR);
        interest = interest.safeDiv(PERCENT);
        interest = interest.safeMul(_borrow_day);
        interest = interest.safeMul(100); //分子分母同时*100
        interest = interest.safeDiv(36525);
        return interest;
    }

    //偿还usda总量 Total Amount = 初始借款 Borrowed + 利息 Interest
    function calRepayUsdaTotalAmount(
        uint256 _init_borrowed_amount,
        uint256 _interest
    ) public override view returns (uint256) {
        uint256 total_amount = _init_borrowed_amount.safeAdd(_interest);
        return total_amount;
    }

    //还款金额 Repay USDA = （提现抵押品数量 Withdraw Collateral Amount * Collateral Price 抵押品价格） /  提现比例 Withdraw Ratio
    function calRepayUsda(
        uint256 _withdraw_collateral_amount,
        uint256 _collateral_price,
        uint256 _withdraw_ratio
    ) public override view returns (uint256) {
        uint256 repay_usda = _withdraw_collateral_amount.safeMul(
            _collateral_price
        );
        repay_usda = repay_usda.safeMul(PERCENT).safeDiv(_withdraw_ratio);
        return repay_usda;
    }

    //提现抵押品数量 Withdraw Collateral Amount= （用户还款 Repay USDA * 提现比例 Withdraw Ratio ）/ Collateral Price 抵押品价格
    function calWithdrawCollateralAmount(
        uint256 _repay_usda,
        uint256 _withdraw_ratio,
        uint256 _collateral_price
    ) public override view returns (uint256) {
        uint256 withdraw_collateral_amount = _repay_usda
            .safeMul(_withdraw_ratio)
            .safeDiv(PERCENT);
        withdraw_collateral_amount = withdraw_collateral_amount.safeDiv(
            _collateral_price
        );
        return withdraw_collateral_amount;
    }

    //偿还后剩余借款 Borrowed USDA After Repay = 实际借出USDA数量 Effective Borrowed * （1 - 偿还比例 Repay Ratio）
    function calBorrowedUSDAAfterRepay(
        uint256 _effective_borrowed,
        uint256 _repay_ratio
    ) public override view returns (uint256) {
        uint256 borrowed_usda_after_repay = _effective_borrowed
            .safeMul(PERCENT)
            .safeDiv(_repay_ratio);
        borrowed_usda_after_repay = _effective_borrowed.safeSub(
            borrowed_usda_after_repay
        );
        return borrowed_usda_after_repay;
    }

    //预期剩余抵押品 Expected Collateral After Withdraw = 实际存入抵押品数量 Effective Collateral Amount - 提现抵押品数量 Collateral Withdraw Amount
    function calExpectedCollateralAfterWithdraw(
        uint256 _effective_collateral_amount,
        uint256 _collateral_withdraw_amount
    ) public override view returns (uint256) {
        uint256 expected_collateral_after_withdraw = _effective_collateral_amount;
        expected_collateral_after_withdraw = expected_collateral_after_withdraw
            .safeSub(_collateral_withdraw_amount);
        return expected_collateral_after_withdraw;
    }

    //预期清算价格 Expected Liquidation Price = 抵押品价格 Collateral Price *  [ 偿还后剩余借款 Borrowed USDA After Repay / (预期剩余抵押品 Expected Collateral After Withdraw * 抵押品价格 Collateral Price * 清算比率 Liquidation Ratio）]
    function calRepayExpectedLiquidationPrice(
        uint256 _collateral_price,
        uint256 _borrowed_usda_after_repay,
        uint256 _expected_collateral_after_withdraw,
        uint256 _liquidation_ratio
    ) public override view returns (uint256) {
        uint256 tmp = _expected_collateral_after_withdraw.safeMul(
            _collateral_price
        );
        tmp = tmp.safeMul(PERCENT).safeDiv(_liquidation_ratio);
        uint256 buar = _borrowed_usda_after_repay.safeDiv(tmp);
        uint256 expected_liquidation_price = _collateral_price.safeMul(buar);
        return expected_liquidation_price;
    }
//repay end
//withdraw start
    /*
    公式：  Max Withdrawable Ratio = 1 - （实际借款 Effective Borrowed + 截止当前产生的利息 Interest）/ （最大抵押率 MCR * 实际抵押品数量 Effective Collateral Amount * 抵押品价格 Collateral Price）
    */
    function maxWithdrawableRatio(
        uint256 _effective_borrowed,
        uint256 _interest,
        uint256 _MCR,
        uint256 _effective_collateral_amount,
        uint256 _collateral_price
    ) public override view returns (uint256) {
        uint256 borrow = _effective_borrowed.safeAdd(_interest);
        uint256 ration = _MCR.safeMul(_effective_collateral_amount).safeMul( _collateral_price);
        ration = ration.safeDiv(PERCENT);
        //1-borrow.safeDiv(r)   ==> (r-borrow)*8位小数/r => 这样才可以等于整数
        // uint256 ration = borrow.safeDiv(r);
        // return ration;
        uint n = ration.safeSub(borrow);
        n = n.safeMul(decimal);
        uint256 max_withdrawable_ratio = n.safeDiv(ration);
        return max_withdrawable_ratio;
    }

    /*
    公式：预期清算价格 Expected Liquidation Price = 抵押品价格 Collateral Price * [ (实际借款 Effective Borrowed + 截止当前产生的利息 Interest) / （预期剩下的抵押品价值 Expected Collateral After Withdraw * 清算比率 Liquidation Ratio）]
     */
    function withdrawablExpectedLiquidationPrice(
        uint256 _collateral_price,
        uint256 _effective_borrowed,
        uint256 _interest,
        uint256 _expected_collateral_after_withdraw,
        uint256 _liquidation_ratio
    ) public override view returns (uint256) {
        uint256 borrow = _effective_borrowed.safeAdd(_interest);
        if(borrow==0){
            return 0;
        }
        uint256 tmp = _expected_collateral_after_withdraw
            .safeMul(_liquidation_ratio)
            .safeDiv(PERCENT);
        uint256 price = borrow.safeDiv(tmp);
        price = price.safeMul(_collateral_price);
        return price;
    }
 /*
    用户选择可提取抵押品的数量，不超过 Collateral Amount=最大值是 最大可提取抵押品比例 Maximum Withdrawable Ratio * 存入抵押品数量 Collateral Amount
     */
    function withdrawCollateralAmount(
        uint256 _maximum_withdrawable_ratio,
        uint256 _collateral_amount
    ) public override view returns (uint256){
        uint256 withdraw_collateral_amount = _maximum_withdrawable_ratio.safeMul(_collateral_amount);
        withdraw_collateral_amount = withdraw_collateral_amount.safeDiv(PERCENT);
        return withdraw_collateral_amount;
    }
    //withdraw end


    //my position start
    /*Effective Liquidation Price：我的头寸目前的清算价格
    说明：计算结果。
    公式：实际清算价格 Effective Liquidation Price = 抵押品价格 Collateral Price * [ (实际借款 Effective Borrowed + 截止当前产生的利息 Interest) / (实际抵押品总价值 Effective Collateral Amount * 抵押品价格 Collateral Price * 清算比率 Liquidation Ratio)]
    */
    function myEffectiveLiquidationPrice(
        uint256 _collateral_price,
        uint256 _effective_borrowed,
        uint256 _interest,
        uint256 _collateral_amount,
        uint256 _liquidation_ratio
    ) public override view returns (uint256){
        uint256 effective_liquidation_price = _effective_borrowed.safeAdd(_interest);
        uint256 t_liquidation = _collateral_amount.safeMul(_collateral_price).safeMul(PERCENT).safeDiv(_liquidation_ratio);
        effective_liquidation_price = _collateral_price.safeMul(effective_liquidation_price).safeDiv(t_liquidation);
        return effective_liquidation_price;
    }
    /*
    USDA Left To Borrow：我的头寸在 MCR 的范围内，还可以借贷多少 USDA。
    说明：计算结果。
    公式：剩余可借贷 USDA Left To Borrow = 实际抵押品数量 Effective Collateral Amount * 抵押品价格 Collateral Price * 最大质押率 MCR - 已借出金额 USDA Borrowed - 截至当前的利息 Interest
    */
    function myUSDALeftToBorrow(
        uint256 _collateral_amount,
        uint256 _collateral_price,
        uint256 _MCR,
        uint256 _effective_borrowed,
        uint256 _interest
    ) public override view returns (uint256){
        uint256 USDA_left_to_borrow = _collateral_amount.safeMul(_collateral_price).safeMul(_MCR);
        USDA_left_to_borrow = USDA_left_to_borrow.safeSub(_effective_borrowed).safeSub(_interest);
        return USDA_left_to_borrow;
    }

    //my position end
}
contract SystemContract is BaseContract {
    using SafeMath for uint256;

    uint8 public idx_MCR = 0;
    uint8 public idx_max_VCR = 1;
    uint8 public idx_liquidation_ratio = 2;
    uint8 public idx_APR = 3;
    uint8 public idx_borrow_ree = 4;
    //Normal Mode Liquidation Fee
    uint8 public idx_normal_liquidation_fee = 5;
    //Recovery Mode Liquidation Fee
    uint8 public idx_recovery_liquidation_fee = 6;
    uint8 public idx_APY = 7;
    
    uint16[8]  parameter = [8500, 8000, 9000, 250, 50, 400, 300,1];

    uint8 public mode_normal = 0;
    uint8 public mode_recovery = 1;
    uint8 public mode = mode_normal;
    
    function getSysParameter(uint8 _indx)
        public
        view
        returns (uint256)
    {
        return parameter[_indx];
    }
    //根据不同模式获取MCR
    function getMCR()
        public
        view
        returns (uint256)
    {
        if(mode == mode_normal){
            return getSysParameter(idx_MCR);
        }
        return getSysParameter(idx_max_VCR);
    }
    //根据不同模式获取不同的清算率
    function getLiquidationFee()
        public
        view
        returns (uint256)
    {
        if(mode == mode_normal){
            return getSysParameter(idx_normal_liquidation_fee);
        }
        return getSysParameter(idx_recovery_liquidation_fee);
    }
    //设定模式
    function setMode(uint8 _mode_name)public{
        mode = _mode_name;
    }
    function getMode() public view returns(uint8){
        return mode ;
    }
}

contract VaultContract is SystemContract {
    using SafeMath for uint256;
    // uint8 public t_idx_TBA = 0;//实际借出 指本帐户当前
    // uint8 public t_idx_TIIA = 1;//实际利息
    uint8 public t_idx_VTBA = 1;//金库总借出
    uint8 public t_idx_VTIA = 2;//金库总利息
    uint8 public t_idx_VTCA = 3;//金库抵押品总数

    // uint256 public total_borrow_amount; //实际借出
    // uint256 public total_interest_amount; //实际利息
    uint256 public vault_t_borrow_amount; //金库总借出
    uint256 public vault_t_interest_amount; //金库总利息
    uint256 public vault_t_collateral_amount; //金库抵押品总数

    /**
    reponse:
        金库总借出
        金库总利息
        金库抵押品总数
    */
    function refreshVault()public view returns(uint256,uint256,uint256){
        return (vault_t_borrow_amount, vault_t_interest_amount, vault_t_collateral_amount);
    }

    function calVaultAmount(uint8 _type,uint256 _amount,bool _isAdd)public{
        if(t_idx_VTBA == _type){
            addVaulTBorrowA(_amount,_isAdd); 
        }
        if(t_idx_VTIA == _type){
            addVaulTInterestA(_amount,_isAdd); 
        }
        if(t_idx_VTCA == _type){
            addVaulTCollateralA(_amount,_isAdd); 
        }
    }

    function addVaulTBorrowA(uint256 _amount,bool _isAdd)private{
        if(_isAdd){
            vault_t_borrow_amount = vault_t_borrow_amount.safeAdd(_amount);
        }else{
            vault_t_borrow_amount = vault_t_borrow_amount.safeSub(_amount);
        }
    }

    function addVaulTInterestA(uint256 _amount,bool _isAdd)private{
        if(_isAdd){
            vault_t_interest_amount = vault_t_interest_amount.safeAdd(_amount);
        }else{
            vault_t_interest_amount = vault_t_interest_amount.safeSub(_amount);
        }
    }

    function addVaulTCollateralA(uint256 _amount,bool _isAdd)private{
        if(_isAdd){
            vault_t_collateral_amount = vault_t_collateral_amount.safeAdd(_amount);
        }else{
            vault_t_collateral_amount = vault_t_collateral_amount.safeSub(_amount);
        }
    }
}

contract BorrowContract is VaultContract,AlgorithmContract
{
    using SafeMath for uint256;
    address token;
    //userAddress,BorrowInfo
    mapping(address =>  BorrowInfo) public borrow_info;
    struct BorrowInfo {
        uint256 borrow_acquired_amount; // 总实际借出数量
        uint256 borrow_time; //开始借的时间,秒
        uint256 collateral_amount; //抵押的数量 
        uint256 collateral_ratio; //抵押率
        uint16  repay_done; // 0未开始偿还，1偿还完成, 2偿还一部分
    }

    constructor(address _token) {
        token = _token;
    }
//借款费用: Borrow Fee Archimedes 收到的 
    function getBorrowFeeArchimedes(
        uint256 _collateral_amount,
        uint256 _collateral_ratio,
        uint256 _collateral_price
    ) public view  returns (uint256) {
        uint256 _borrow_fee = getSysParameter(idx_borrow_ree);
        uint256 borrow_fee_archimedes = calBorrowFeeArchimedes(_collateral_amount,_collateral_ratio,_borrow_fee,_collateral_price);
        return borrow_fee_archimedes;
    }

    //获取头部健康
    function getHealthRate(uint256 _liquidation_price)public view returns(uint256){
        uint256 collateral_price_revised = getCollateralPriceRevised();
        uint256 collateral_price = getCollateralPrice();
        uint256 health_rate = calHealthRate(collateral_price_revised, _liquidation_price, collateral_price );
        return health_rate;
    }

    /*
    预期清算价格，不返回给前端
    */
    function getExpectedLiquidationPrice(
        uint256 _collateral_ratio
    ) public view returns (uint256) {
        uint256 collateral_price = getCollateralPrice();
        uint256 liquidation_ratio = getSysParameter(
            idx_liquidation_ratio
        );
        uint256 price = calExpectedLiquidationPrice(
            collateral_price,
            _collateral_ratio,
            liquidation_ratio
        );
        return price;
    }

    /*
    从预言机获取价格
     */
    function getCollateralPrice()public  view returns (uint256)
    {
        uint256 price = 1;
        return price;
    }

    function getCollateralPriceRevised()public  view returns (uint256)
    {
        uint256 price = getCollateralPrice().safeMul(decimal);
        return price;
    }

    //抵押率的计算：所借usda的价值/(抵押品数量*price)
    function getCollateralRation()public  view returns (uint256)
    {
        uint256 price = 1;
        return price;
    }

    /* 模式 转换 */
    function transformModel(uint256 _collateral_ration) public{
        uint256  collateral_ration = getCollateralRation();
        uint256  mcr = getSysParameter(idx_MCR);
        uint256  max_vcr = getSysParameter(idx_max_VCR);
        if(collateral_ration >= idx_max_VCR && collateral_ration <= mcr ){
            //恢复模式
            setMode(mode_normal);
        }else if(collateral_ration < idx_max_VCR){
            //正常模式
            setMode(mode_recovery);
        }
    }
    /* 获取查式 */

    //借了多少天
    function borrowDay() public view returns (uint256) {
        uint256 currTime = currTimeInSeconds();
        uint256 subTime = currTime.safeSub(borrow_info[msg.sender].borrow_time);
        uint256 subDay = subTime.safeDiv(86400).safeMul(100);//365.25解决这个小数问题
        //不足一天按一天算
        if(subDay<1){
            subDay = 1;
        }
        return subDay;
    }
    function TsubSeconds() public  {
        uint256 time = borrow_info[msg.sender].borrow_time;
        uint256 t = time.safeSub(86400);
        borrow_info[msg.sender].borrow_time = t;
    }
    function currTimeInSeconds() public view returns (uint256) {
        return block.timestamp;
    }

    //repay start
     function isExistEntry() public view returns(bool){
        return borrow_info[msg.sender].borrow_time>0;
    }

}
contract RepayContract is BorrowContract {
    using SafeMath for uint256;
    //     userAddress,   RepayInfo
    mapping(address => RepayInfo) public repay_info;
    struct RepayInfo {
        uint256 repay_borrow_acquired_amount; //偿还的数量
        uint256 interest; //利息
        uint256 unlock_collateral_amount;//解锁的抵押品
    } 
    constructor(address _token) public BorrowContract(_token) {}
    // uint256 remain_repay_amount;//剩余待偿还的usda
    function getRemainRepayAmount()public view returns(uint256){
        uint256 remain_repay_amount = borrow_info[msg.sender].borrow_acquired_amount;
        remain_repay_amount = remain_repay_amount.safeSub(repay_info[msg.sender].repay_borrow_acquired_amount);
        return remain_repay_amount;
    }

    //余下的抵押品数量
    function getRemainCollateralAmount()public view returns(uint256){
        uint256 remain_collateral_amount = borrow_info[msg.sender].collateral_amount.safeSub(repay_info[msg.sender].unlock_collateral_amount);
        return remain_collateral_amount;
    }
   
    //全部偿还
     function _repayTotal()public{
         //加锁
         //偿还总的，进行计算
         //偿还全部的usda
        uint256 t_interest;
        uint256 t_borrow_usda;
        uint256 t_collateral_amount;
        (
            ,
            t_interest,
            t_borrow_usda,
            t_collateral_amount
        ) = _calRepayTotal();
       
        //borrow_info处理
        //直接删除
        // delete borrow_info[msg.sender];
        borrow_info[msg.sender].repay_done=1;
         //入金库-利息计算
        calVaultAmount(t_idx_VTIA, t_interest, true);
        //处理各币的转移
        addRepayInfo(t_collateral_amount,t_borrow_usda,t_interest);
     }

         //部分偿还
     function _repayPartly( uint256 _t_repay_partly_usda,  uint256 _withdraw_ratio)public{
            uint256 remain_repay_amount=_t_repay_partly_usda;
            uint256 total_repay_usda;
            uint256 interest;
            uint256 repay_partly_usda;
            uint256 withdraw_collateral_amount;
            if(remain_repay_amount >= getRemainRepayAmount()){
                //全部偿还
                _repayTotal();
            }else{ 
            //部分偿还
                (
                total_repay_usda,
                interest,
                repay_partly_usda,
                withdraw_collateral_amount
                ) = calRepayPartlyUsda( remain_repay_amount , _withdraw_ratio);
                addRepayInfo(withdraw_collateral_amount,repay_partly_usda,interest);
                //borrow_info处理
                borrow_info[msg.sender].repay_done=2;
            }  
     }

    /* 偿还 */
    function addRepayInfo(uint _unlock_collateral_amount,uint256 _repay_borrow_acquired_amount,uint256 _interest) public{
        if(repay_info[msg.sender].repay_borrow_acquired_amount==0){
            RepayInfo memory repay = RepayInfo({
                        repay_borrow_acquired_amount:_repay_borrow_acquired_amount,
                        interest:_interest,
                        unlock_collateral_amount: _unlock_collateral_amount
                    });
            repay_info[msg.sender] = repay;
        }else{
            uint256 repay_amount = repay_info[msg.sender].repay_borrow_acquired_amount;
            uint256 interest = repay_info[msg.sender].interest;
            uint256 unlock_collateral_amount = repay_info[msg.sender].unlock_collateral_amount;
            repay_info[msg.sender].repay_borrow_acquired_amount = repay_amount.safeAdd(_repay_borrow_acquired_amount);
            repay_info[msg.sender].interest = interest.safeAdd(_interest);
            repay_info[msg.sender].unlock_collateral_amount = unlock_collateral_amount.safeAdd(_unlock_collateral_amount);
        }
    }

    /* 
  全部偿还
    total_repay_usda, 总偿还
    interest, 利息
    remain_repay_amount, 余的usda , 即此次偿还的本金
    remain_collateral_amount 余下抵押的数量，即此次要解锁的抵押品
     */
    function _calRepayTotal()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 APR = getSysParameter( idx_APR);
        uint256 borrow_day = borrowDay();
        uint256 remain_repay_amount = getRemainRepayAmount();
        uint256 interest = calInterest(remain_repay_amount, APR, borrow_day);
        uint256 total_repay_usda = calRepayUsdaTotalAmount(
            remain_repay_amount,
            interest
        );
        uint256 remain_collateral_amount = getRemainCollateralAmount();
        return (
            total_repay_usda,
            interest,
            remain_repay_amount,
            remain_collateral_amount
        );
    }

    //repay partly start
    /* 
    每一项的部分 ,利息和本金
    total_repay_usda, 总偿还
    interest, 利息
    _repay_partly_usda, 计划偿还本金数
    withdraw_collateral_amount,可提现数量
     */
    function calRepayPartlyUsda(uint256 _repay_partly_usda,  uint256 _withdraw_ratio)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 APR = getSysParameter( idx_APR);
        uint256 borrow_day = borrowDay();
        uint256 collateral_price = getCollateralPrice();
        uint256 interest = calInterest(_repay_partly_usda, APR, borrow_day);
        uint256 total_repay_usda = calRepayUsdaTotalAmount(
            _repay_partly_usda,
            interest
        );
        uint256 withdraw_collateral_amount = calWithdrawCollateralAmount(_repay_partly_usda, _withdraw_ratio, collateral_price);
        return (
            total_repay_usda,
            interest,
            _repay_partly_usda,
            withdraw_collateral_amount
        );
    }

    /* 
    前端显示需要
        获取部分 总的偿还usda，总的利息，总的借的usda,总抵押数 
    */
    function _calRepayPartly( uint256 _t_repay_partly_usda,  uint256 _withdraw_ratio)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 total_repay_usda;//偿还的总的usda(本金+利息)
        uint256 interest;// 偿还总的利息
        uint256 repay_partly_usda;// 偿还总的本金
        uint256 withdraw_collateral_amount;//可获得解锁抵押的总数
        uint256 remain_repay_amount = getRemainRepayAmount(); // 余下要还的usda
        
        if(_t_repay_partly_usda<remain_repay_amount){
            (
            total_repay_usda,
            interest,
            repay_partly_usda,
            withdraw_collateral_amount
            ) = calRepayPartlyUsda( _t_repay_partly_usda, _withdraw_ratio);
        } 
        return (
            total_repay_usda,
            interest,
            repay_partly_usda,withdraw_collateral_amount
        );
    }
    /*
       偿还部分的预期清算价格计算
     */
    function getRepayExpectedLiquidationPrice(
        uint256 _borrowed_usda_after_repay,
        uint256 _expected_collateral_after_withdraw
    )public view returns(uint256){
        uint256 collateral_price = getCollateralPrice();
        uint256 liquidation_ratio = getSysParameter( idx_liquidation_ratio);
        uint256 repay_expected_liquidation_price = calRepayExpectedLiquidationPrice(
         collateral_price,
         _borrowed_usda_after_repay,
         _expected_collateral_after_withdraw,
         liquidation_ratio
        );
        return repay_expected_liquidation_price;
    }
   
    //repay partly  end
}

//提现合约  开始
contract WithdrawContract is RepayContract{
    using SafeMath for uint256;
    mapping(address => uint256) public withdraw_info; 
    constructor(address _token) public RepayContract(_token) {}
    /* 计算清算价格 */
    function calWithdrawablExpectedLiquidationPrice(
        uint256 collateral_withdraw_amount // 根据提现率算出提取多少的量
    ) public  view returns (uint256) {
        uint256 collateral_price = getCollateralPrice();
        uint256 effective_borrowed = getRemainRepayAmount();
        uint256 interest = curRemainInterest();//余下的利息
        uint256 _expected_collateral_after_withdraw = getRemainCollateralAmount();
        uint256 liquidation_ratio=getSysParameter(idx_liquidation_ratio);
        return withdrawablExpectedLiquidationPrice(collateral_price,effective_borrowed,interest,_expected_collateral_after_withdraw,liquidation_ratio);
    }
    //最大提取率
    function calMaxWithdrawableRatio() public  view returns (uint256) {
        uint256 effective_borrowed = getRemainRepayAmount();
        if(effective_borrowed <= 0){
            return 10000;
        }
        uint256 interest = soFarInterest();
        uint256 MCR = getMCR();
        uint256 effective_collateral_amount = getRemainCollateralAmount();
        uint256 collateral_price = getCollateralPrice();
        return maxWithdrawableRatio(effective_borrowed, interest, MCR, effective_collateral_amount, collateral_price);
    }
    //用户可提取的抵押品数量
    function getWithdrawCollateralAmount(
        uint256 _maximum_withdrawable_ratio
    ) public view returns (uint256){
        uint256 collateral_amount = repay_info[msg.sender].unlock_collateral_amount;
        return withdrawCollateralAmount(_maximum_withdrawable_ratio,collateral_amount );
    }
    //到目前为止产生的利息
    function soFarInterest()public view returns(uint256){
        //以前的计算好的利息，
        uint256 interest = repay_info[msg.sender].interest;
        //余下的未计算的利息
        uint256 current_interest = curRemainInterest();
        interest = interest.safeAdd(current_interest);
        return interest;
    }

    function curRemainInterest()public view returns(uint256){
        //余下的未计算的利息
        uint256 APR = getSysParameter( idx_APR);
        uint256 borrow_day = borrowDay();
        uint256 remain_repay_amount = getRemainRepayAmount();
        uint256 current_interest = calInterest(remain_repay_amount, APR, borrow_day);
        return current_interest;
    }

    //还余多少没有提现
    function getRemainWithdrawCollateralAmount()public view returns(uint256){
        uint256 remain_withdraw = repay_info[msg.sender].unlock_collateral_amount;
        remain_withdraw = remain_withdraw.safeSub(withdraw_info[msg.sender]);
        return remain_withdraw;
    }
    //提取
    function _withdraw(uint256 _withdraw_amount)public{
        //最大可提取抵押品比例
        uint256 max_withdrawable_ratio = calMaxWithdrawableRatio();
        //最大可提取抵押品
        uint256 withdraw_collateral_amount = getWithdrawCollateralAmount(max_withdrawable_ratio);
        require(_withdraw_amount>withdraw_collateral_amount,"_withdraw(). more than max amount");
        //入提取库
        withdraw_info[msg.sender] = withdraw_info[msg.sender].safeAdd(_withdraw_amount);
    }
}
//提现合约  结束

// my position start
contract MyPositionContract is WithdrawContract{
    constructor(address _token) public WithdrawContract(_token) {}
    /*Effective Liquidation Price：我的头寸目前的清算价格
    说明：计算结果。
    公式：实际清算价格 Effective Liquidation Price = 抵押品价格 Collateral Price * [ (实际借款 Effective Borrowed + 截止当前产生的利息 Interest) / (实际抵押品总价值 Effective Collateral Amount * 抵押品价格 Collateral Price * 清算比率 Liquidation Ratio)]
    */
    function getMyEffectiveLiquidationPrice() public  view returns (uint256){
        uint256 collateral_price = getCollateralPrice();
        uint256 effective_borrowed = borrow_info[msg.sender].borrow_acquired_amount;
        uint256 interest = soFarInterest();
        uint256 collateral_amount = borrow_info[msg.sender].collateral_amount;
        uint256 liquidation_ratio=getSysParameter(idx_liquidation_ratio);
        return myEffectiveLiquidationPrice(collateral_price, effective_borrowed, interest,collateral_amount, liquidation_ratio);
    }
    /*
    USDA Left To Borrow：我的头寸在 MCR 的范围内，还可以借贷多少 USDA。
    说明：计算结果。
    公式：剩余可借贷 USDA Left To Borrow = 实际抵押品数量 Effective Collateral Amount * 抵押品价格 Collateral Price * 最大质押率 MCR - 已借出金额 USDA Borrowed - 截至当前的利息 Interest
    */
    function getMyUSDALeftToBorrow() public view returns (uint256){
        uint256 collateral_amount = borrow_info[msg.sender].collateral_amount;
        uint256 collateral_price = getCollateralPrice();
        uint256 MCR = getMCR();
        uint256 effective_borrowed = borrow_info[msg.sender].borrow_acquired_amount;
        uint256 interest = soFarInterest();
        return myUSDALeftToBorrow(collateral_amount, collateral_price, MCR, effective_borrowed, interest);
    }

}

//my position end

/* borrow操作合约*/
contract BorrowOpContract is MyPositionContract {
    using SafeMath for uint256;
     constructor(address _token) public MyPositionContract(_token) {}
    /*
     功能：根据用户对borrow的设定，返回各值
     request:
        _collateral_ratio  :抵押率
        _collateral_amount :抵押数量
     reponse:
        清算价格
        头部健康率
        用户实际可以收到usda
        借款费用
     */
    function refreshBorrow(uint256 _collateral_ratio,uint256 _collateral_amount)public view returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        /*用户输入ration, 借贷量所占抵押品的比例。此比例不可以超过 MCR（Normal Mode） 或者 Max VCR（Recovery Mode） */
        uint256 mcr = getMCR();
        require(_collateral_ratio <= mcr,"_collateral_ratio > mcr is error.");
        uint256 liquidation_price = getExpectedLiquidationPrice(_collateral_ratio);
        uint256 health_rate = getHealthRate(liquidation_price);
        //计算用户实际收到的USDA
        uint256 collateral_amount = _collateral_amount;
        uint256 collateral_ratio = _collateral_ratio;
        uint256 borrow_fee = getSysParameter( idx_borrow_ree);
        uint256 collateral_price = getCollateralPrice();
        uint256 acquired_usda = calAcquiredUSDA(
            collateral_amount,
            collateral_ratio,
            borrow_fee,
            collateral_price
        );
        uint256 borrow_fee_archimedes = getBorrowFeeArchimedes(collateral_amount,collateral_ratio,collateral_price );
        return (liquidation_price, health_rate, acquired_usda,borrow_fee_archimedes);
    }

    /*
     功能：借贷
     request:
        _collateral_ratio  :抵押率
        _collateral_amount :抵押数量
        _borrow_usda_amount : 借的usda数量
     reponse:
        true or false
     */
    function borrow(uint256 _collateral_ratio, uint256 _collateral_amount) public  returns(bool) {
        //铸造usda的数量
        //转给当前用户usda
        //抵押的数量存入
        require(!isExistEntry(),"please pay first");
        uint256 liquidation_price;
        uint256 health_rate;
        uint256 acquired_usda;
        uint256 borrow_fee_archimedes;
        ( liquidation_price, health_rate, acquired_usda, borrow_fee_archimedes) = refreshBorrow(_collateral_ratio, _collateral_amount);
        BorrowInfo memory info = BorrowInfo({
            borrow_acquired_amount: acquired_usda,
            borrow_time: currTimeInSeconds(),
            collateral_amount: _collateral_amount,
            repay_done: 0,
            collateral_ratio: _collateral_ratio
        });
        borrow_info[msg.sender]=info;
        //金库总借出
        calVaultAmount(t_idx_VTBA, acquired_usda, true);
        //入金库-总抵押
        calVaultAmount(t_idx_VTCA, _collateral_amount, true);
        return true;
    }

    /*
     功能：刷新总偿还
     request:
        
     reponse:
        总偿还usda
        利息usda
        实际借的usda
        解锁的抵押品数量
     */
    function refreshRepayTotal()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        //偿还全部的usda
        uint256 t_total_repay_usda;
        uint256 t_interest;
        uint256 t_borrow_usda;
        uint256 t_collateral_amount;
        (
            t_total_repay_usda,
            t_interest,
            t_borrow_usda,
            t_collateral_amount
        ) = _calRepayTotal();
        return (
            t_total_repay_usda,
            t_interest,
            t_borrow_usda,
            t_collateral_amount
        );
    }
    /*
     功能：刷新总偿还
     request:
        _total_repay_usda : 总偿还usda数量
     reponse:
        true or false
     */
    function repayTotal() public returns(bool) {
        //计算总的偿还多少
         _repayTotal();
         return true;
    }

     /*
     功能：刷新部分偿还-1
    request：
        _withdraw_ratio 提现比率
        _repay_usda 偿还usda数量
        _withdraw_collateral_amount->这个由前端计算，后端不作计算 提现抵押品数量
    reponse：
        总偿还(本金+利息)，
        总利息,
        偿还总的本金,
        可获得提现的总数
    */
    function refreshRepayPartlyOne(uint256 _withdraw_ratio,uint256 _repay_usda)public view returns (uint256,uint256,uint256,uint256) {
        //根据还本金计算各值
        uint256 t_total_repay_usda; //偿还的总的usda(本金+利息)
        uint256 t_interest; // 偿还总的利息
        uint256 t_repay_partly_usda; // 偿还总的本金
        uint256 t_withdraw_collateral_amount; //可获得提现的总数
        (t_total_repay_usda,t_interest,t_repay_partly_usda,t_withdraw_collateral_amount) = _calRepayPartly(  _repay_usda,  _withdraw_ratio);
        return (t_total_repay_usda,t_interest,t_repay_partly_usda,t_withdraw_collateral_amount);
    }
    
    /* 上面的分成两部分返回，因返回的参数太多了，编译不通过 */
    /*
     功能：刷新部分偿还-2
    request：
        _withdraw_ratio 提现比率
        _repay_usda 偿还usda数量
        _withdraw_collateral_amount->这个由前端计算，后端不作计算 提现抵押品数量
    reponse：
        偿还后剩余借款 Borrowed USDA After Repay 
        预期剩余抵押品 Expected Collateral After Withdraw 
        预期清算价格 Expected Liquidation Price 
        头部健康
    */
    function refreshRepayPartlyTwo(uint256 _withdraw_ratio,uint256 _repay_usda)public view returns (uint256,uint256,uint256,uint256) {
        //根据还本金计算各值
        uint256 t_total_repay_usda; //偿还的总的usda(本金+利息)
        uint256 t_interest; // 偿还总的利息
        uint256 t_repay_partly_usda; // 偿还总的本金
        uint256 t_withdraw_collateral_amount; //可获得提现的总数
        (t_total_repay_usda,t_interest,t_repay_partly_usda,t_withdraw_collateral_amount) = _calRepayPartly(  _repay_usda,  _withdraw_ratio);
        //取余下的数量
        uint256 remain_repay_amount = getRemainRepayAmount();//偿还后剩余借款
        uint256 remain_collateral_amount = getRemainCollateralAmount();//预期剩余抵押品
        uint256 t_borrowed_usda_after_repay = remain_repay_amount.safeSub(t_repay_partly_usda); //偿还后剩余借款
        uint256 t_expected_collateral_after_withdraw = remain_collateral_amount.safeSub(t_withdraw_collateral_amount); //预期剩余抵押品
        //预期清算价格
        uint256 repay_expected_liquidation_price = getRepayExpectedLiquidationPrice(t_borrowed_usda_after_repay,t_expected_collateral_after_withdraw);
        //头部健康
        uint256 health_rate = getHealthRate(
            repay_expected_liquidation_price
        );
        return (t_borrowed_usda_after_repay, t_expected_collateral_after_withdraw, repay_expected_liquidation_price, health_rate);
    }

    /*
     功能：部分偿还 操作
    request：
        _t_repay_partly_usda ：偿还usda数量
        _withdraw_ratio ：提现比率
    reponse：
        true or false
    */
    function repayPartly(uint256 _t_repay_partly_usda , uint256 _withdraw_ratio)public returns(bool){
        _repayPartly( _t_repay_partly_usda,   _withdraw_ratio);
        return true;
    }
    //repay end

    //withdraw 提取 start
 /*
    功能：刷新 提现
    request：
        
    reponse：
        最大可提取抵押品比例
        最大可提取抵押品
        预期还剩下的抵押品数量
        新的清算价格
        头寸健康度
    */
    function refreshWithdrawMax()public view returns(uint256,uint256,uint256,uint256,uint256){
        //最大可提取抵押品比例
        uint256 max_withdrawable_ratio = calMaxWithdrawableRatio();
        //最大可提取抵押品
        uint256 withdraw_collateral_amount = getWithdrawCollateralAmount(max_withdrawable_ratio);
        //预期还剩下的抵押品数量
        uint256 remain_collateral_amount = getRemainCollateralAmount();
        //新的清算价格
        uint256 liquidation_price = calWithdrawablExpectedLiquidationPrice(withdraw_collateral_amount);
         //头部健康
        uint256 health_rate = getHealthRate(
            liquidation_price
        );
        return(max_withdrawable_ratio, withdraw_collateral_amount, remain_collateral_amount,liquidation_price, health_rate);
    }

     /*
    功能：刷新 提现-滑动
    request：
        _withdraw_ratio ：提现比率
    reponse：
        最大可提取抵押品
        预期还剩下的抵押品数量
        新的清算价格
        头寸健康度
    */
    function refreshWithdrawSliding(uint256 _withdraw_ratio)public view returns(uint256,uint256,uint256,uint256){
        require(_withdraw_ratio > 0 ,"_withdraw_ratio <= 0");
        uint256 max_withdrawable_ratio = calMaxWithdrawableRatio();
        require(max_withdrawable_ratio >= _withdraw_ratio ,"max_withdrawable_ratio < _withdraw_ratio");
        //最大可提取抵押品比例
        
        //最大可提取抵押品
        uint256 withdraw_collateral_amount = getWithdrawCollateralAmount(_withdraw_ratio);
        //预期还剩下的抵押品数量 - 上面的数量
        uint256 remain_withdraw_amount = getRemainWithdrawCollateralAmount();
        remain_withdraw_amount = remain_withdraw_amount.safeSub(withdraw_collateral_amount);
        //新的清算价格
        uint256 liquidation_price = calWithdrawablExpectedLiquidationPrice(withdraw_collateral_amount);
         //头部健康
        uint256 health_rate = getHealthRate(
            liquidation_price
        );
        return(withdraw_collateral_amount, remain_withdraw_amount,liquidation_price, health_rate);
    }

    /*
    功能：提现
    request：
        _withdraw_amount ：提现数量
    reponse：
        true or false
    */
    function withdraw(uint256 _withdraw_amount)public  returns(bool){
        _withdraw(_withdraw_amount);
        return true;
    }
    //提取 end

    // 清算 start
    function isCanClear()public  returns(bool){
        //全部偿还完成
        uint256 remain_repay_amount = getRemainRepayAmount();
        //已全部提现
        uint256 remain_withdraw_amount = getRemainWithdrawCollateralAmount();
        //表示可以清算了
        if(remain_repay_amount == 0 && remain_withdraw_amount == 0){
            return true;
        }
        return false;
    }
    //清除数据
    function clear()public  returns(bool){
        delete withdraw_info[msg.sender];
        delete repay_info[msg.sender];
        delete borrow_info[msg.sender];
    }
    //清算 end

    /*
    功能：My Effective Position
    request：
        _withdraw_amount ：提现数量
    reponse：
        抵押品所代表的美金价值
        借贷总额 Effective Borrowed 
        截止当前产生的利息 Interest
        头部健康
    */
    function refreshMyEffectivePosition()public view returns(uint256,uint256,uint256,uint256){
        //Effective Collateral Value：抵押品所代表的美金价值
        uint256 collateral_price = getCollateralPrice();
        uint256 effective_collateral_value = borrow_info[msg.sender].collateral_amount.safeMul(collateral_price);
        //借贷总额 Effective Borrowed +截止当前产生的利息 Interest
        uint256 current_interest = soFarInterest();
        uint256 borrow_acquired_amount = borrow_info[msg.sender].borrow_acquired_amount;
        //头部健康
        uint256 liquidation_price = getExpectedLiquidationPrice(
            borrow_info[msg.sender].collateral_ratio
        );
        uint256 health_rate = getHealthRate(liquidation_price);
        return(effective_collateral_value,current_interest, borrow_acquired_amount, health_rate);
    }

   
 /*
    功能：Position Statistics
    request：
        
    reponse：
        存入的抵押品代币个数
        我的头寸目前的 APY
        实际清算价格, 
        剩余可借贷 USDA Left To Borrow
        抵押品价格
    */
    function refreshMyPositionStatistics()public view returns(uint256,uint256,uint256,uint256,uint256){
        //存入的抵押品代币个数
        uint256 collateral_amount = borrow_info[msg.sender].collateral_amount; 
        //我的头寸目前的 APY
        uint256 apy = getSysParameter(idx_APY); 
        //实际清算价格
        uint256 liquidation_price = getMyEffectiveLiquidationPrice();
        //剩余可借贷 USDA Left To Borrow
        uint256 USDA_left_to_borrow = getMyUSDALeftToBorrow();
        //抵押品价格
        uint256 collateral_price = getCollateralPrice();

        return (collateral_amount, apy, liquidation_price, USDA_left_to_borrow, collateral_price);
    }
    /*
    功能：系统参数
    request：
    reponse：
        MCR 
        max_VCR 
        liquidation_ratio
        APR
        borrow_ree
        normal_liquidation_fee
        recovery_liquidation_fee
        apy
    */
    function refreshVaultStatistics()public view returns(uint16[8] memory){
        return parameter;
    }
    //My Effective Position end

    /*
    功能：设置系统参数
    request：
        MCR 
        max_VCR 
        liquidation_ratio
        APR
        borrow_ree
        normal_liquidation_fee
        recovery_liquidation_fee
    reponse：
        true or false
    */
    function setStatistics(uint16[7] memory _sys_parameter)public returns(bool){
        parameter = _sys_parameter;
        return true;
    }
    
}