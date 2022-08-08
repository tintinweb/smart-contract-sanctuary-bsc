/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-21
*/

pragma solidity 0.5.16;

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

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

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }


    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Owner {
    address public OwnerAddress;
    address public WaitingAddress;
    uint256 public CreateUpdataTime;
    constructor () internal {
        OwnerAddress = msg.sender;
        WaitingAddress = msg.sender;
        CreateUpdataTime = 0;
    }
    event UpdateCEOApply(address CEOAddress,uint256 CreateUpdataTime);
    event UpdataConfirm(address CEOAddress);

    modifier onlyOwner() {
        require (isOwner(),"You are not the Owner");
        _;
    }

    function isOwner () public view returns (bool){
        return OwnerAddress ==  msg.sender;
    }

    function updateCEOApply (address OwnerAddress_) public onlyOwner{
        require(OwnerAddress != address(0), "GOV: new Owner is address(0)");
        WaitingAddress = OwnerAddress_;
        CreateUpdataTime = block.timestamp;
        emit UpdateCEOApply(WaitingAddress,CreateUpdataTime);
    }

    function updataConfirm () public  {
        require( block.timestamp > CreateUpdataTime + (60*60*24) && CreateUpdataTime!=0, "Time has not expired");
        require (WaitingAddress == msg.sender,'You are not to update the address');
        OwnerAddress = WaitingAddress;
        CreateUpdataTime = 0;
        emit UpdataConfirm(OwnerAddress);
    }
}

contract Token is Owner{
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    //24 => mul
    mapping(uint256 => uint256) private winMultiple;


    // 175 => 24
    mapping(uint256 => uint256) private win;

    //10W 20W 50W 100W 200W 500W 1000W
    mapping(uint256 => uint256) private priceMultiple;

    //1:80 2:13(93) 3:5(98) 4:2(100)
    mapping(uint256 => uint256) private trainRandomNum;

    //1:14 2:11 3:8 4:6
    mapping(uint256 => uint256) private trainRandomTurnNum;

    // 1-3 7-15 19 20
    mapping(uint256 => uint256) private threeTurn;
    // 1 2 7-14 19
    mapping(uint256 => uint256) private fourTurn;
    // 1 7-13 8
    mapping(uint256 => uint256) private fiveTurn;
    // 7-12
    mapping(uint256 => uint256) private sixTurn;

    address public tokenAddress;

    //175
    uint256 private num;

    //32
    uint256 private specialNum;
    //10
    uint256 private noWin;
    //7  17
    uint256 private sx;
    //6  23
    uint256 private ssy;
    //5  28
    uint256 private dsy;
    //4  32
    uint256 private train;

    uint256 private decimals;
    //100
    uint256 private trainRandom;

    //随机数Nonce
    uint256 private randomNonce = 0;

    event winM(uint256 win_);

    event winAmountM(uint256 amount_);

    event winSpecialM(uint256);

    event winSpecialTrun(uint256 number_);

    function setWin(uint256 index,uint256[] memory start_,uint256[] memory end_)public onlyOwner{
        for (uint256 i = 0; i < index; i++) {
            for (uint256 j = start_[i]; j <= end_[i]; j++) {
                win[j] = i+1;
            }
        }
    }

    function setWinMultiple(uint256 indexNum_,uint256[] memory data_)public onlyOwner{
        for (uint256 i = 1; i <= indexNum_; i++) {
            winMultiple[i] = data_[i-1];
        }
    }

    function setPriceMultiple(uint256 indexNum_,uint256[] memory data_)public onlyOwner{
        for (uint256 i = 1; i <= indexNum_; i++) {
            priceMultiple[i] = data_[i-1].mul(10**decimals);
        }
    }

    function setTrainRandomNum(uint256 index,uint256[] memory start_,uint256[] memory end_)public onlyOwner{
        for (uint256 i = 0; i < index; i++) {
            for (uint256 j = start_[i]; j <= end_[i]; j++) {
                trainRandomNum[j] = i+1;
            }
        }
    }

    function setTrainRandomTurnNum(uint256 indexNum_,uint256[] memory data_)public onlyOwner{
        for (uint256 i = 1; i <= indexNum_; i++) {
            trainRandomTurnNum[i] = data_[i-1];
        }
    }

    function setThreeTurn(uint256 indexNum_,uint256[] memory data_)public onlyOwner{
        for (uint256 i = 1; i <= indexNum_; i++) {
            threeTurn[i] = data_[i-1];
        }
    }

    function setFourTurn(uint256 indexNum_,uint256[] memory data_)public onlyOwner{
        for (uint256 i = 1; i <= indexNum_; i++) {
            fourTurn[i] = data_[i-1];
        }
    }

    function setFiveTurn(uint256 indexNum_,uint256[] memory data_)public onlyOwner{
        for (uint256 i = 1; i <= indexNum_; i++) {
            fiveTurn[i] = data_[i-1];
        }
    }

    function setSixTurn(uint256 indexNum_,uint256[] memory data_)public onlyOwner{
        for (uint256 i = 1; i <= indexNum_; i++) {
            sixTurn[i] = data_[i-1];
        }
    }

    function withdraw(address to,uint256 _amount)public onlyOwner {
        IERC20(tokenAddress).safeTransfer(address(to),_amount);
    }


    function setData(uint256 num_,
        uint256 specialNum_,
        uint256 noWin_,
        uint256 sx_,
        uint256 ssy_,
        uint256 dsy_,
        uint256 train_,
        uint256 trainRandom_,
        uint256 decimals_,
        address tokenAddress_
    ) public onlyOwner {
        num = num_;
        specialNum = specialNum_;
        noWin = noWin_;
        sx = sx_;
        ssy = ssy_;
        dsy = dsy_;
        train = train_;
        trainRandom = trainRandom_;
        tokenAddress = tokenAddress_;
        decimals = decimals_;

    }

    function bet(
        uint256 _num1,
        uint256 _num2,
        uint256 _num3,
        uint256 _num4,
        uint256 _num5,
        uint256 _num6,
        uint256 _num7,
        uint256 _num8,
        uint256 _num
    ) public {
        require(priceMultiple[_num]>0);
        uint256  totalAmount_ = _num1.add(_num2).add(_num3).add(_num4);
        totalAmount_ = totalAmount_.add(_num5).add(_num6).add(_num7).add(_num8);
        require(totalAmount_>0);
        totalAmount_ = totalAmount_.mul(priceMultiple[_num]);
        require(IERC20(tokenAddress).balanceOf(address(msg.sender))>totalAmount_);
        uint256 randomNum_ = _random(num);
        uint256 win_ = win[randomNum_];
        emit winM(win_);
        uint256[] memory _numBet = new uint256[](8);
        _numBet[0] = _num1;
        _numBet[1] = _num2;
        _numBet[2] = _num3;
        _numBet[3] = _num4;
        _numBet[4] = _num5;
        _numBet[5] = _num6;
        _numBet[6] = _num7;
        _numBet[7] = _num8;
        uint256 winAmount = getWinAmount(win_,_numBet,priceMultiple[_num]);
        if(totalAmount_ > winAmount){
            IERC20(tokenAddress).safeTransferFrom(address(msg.sender), address(this), totalAmount_.sub(winAmount));
        }
        if(winAmount > totalAmount_){
            IERC20(tokenAddress).safeTransfer(address(msg.sender), winAmount.sub(totalAmount_));
        }
    }

    function _random(uint256 num) internal returns(uint256){
        randomNonce = randomNonce.add(1);
        return  uint256(keccak256(abi.encodePacked(now, msg.sender, randomNonce)))% num;
    }

    function getWinAmount(uint256 winNum_,
        uint256[] memory _numBet,
        uint256 _num
    )private returns(uint256 amount_){
        if(winNum_ == 6 || winNum_ == 18 ){
            uint256 randomNum_ = _random(specialNum);
            if(randomNum_ <= noWin){
                amount_ = 0;
                emit winAmountM(amount_);
                emit winSpecialM(0);
                return amount_;
            }
            if(randomNum_ >noWin && randomNum_ <= sx){
                amount_ = _numBet[0].mul(4);
                amount_ = amount_.mul(_num).mul(winMultiple[1]);
                emit winAmountM(amount_);
                emit winSpecialM(1);
                return amount_;
            }
            if(randomNum_ >sx && randomNum_ <= ssy){
                amount_ = _numBet[1].add(_numBet[2]).add(_numBet[3]);
                amount_ = amount_.mul(_num).mul(winMultiple[3]);
                emit winAmountM(amount_);
                emit winSpecialM(2);
                return amount_;
            }
            if(randomNum_ >ssy && randomNum_ <= dsy){
                uint256 betAmount_ = _numBet[4].add(_numBet[5]).add(_numBet[6]);
                amount_ = betAmount_.mul(_num).mul(winMultiple[4]);
                emit winAmountM(amount_);
                emit winSpecialM(3);
                return amount_;
            }
            if(randomNum_ >dsy){
                uint256 knotsNum_ = trainRandomNum[_random(trainRandom)];
                uint256 turn_ = trainRandomTurnNum[knotsNum_];
                if(knotsNum_ == 1){
                    uint256 number_ = threeTurn[turn_];
                    for(uint i = 0;i<3;i++){
                        uint256 winAmount_ = getAmount(number_.add(i),_numBet,_num);
                        amount_ = amount_.add(winAmount_);
                    }
                    emit winAmountM(amount_);
                    emit winSpecialM(4);
                    emit winSpecialTrun(number_);
                    return amount_;
                }
                if(knotsNum_ == 2){
                    uint256 number_ = fourTurn[turn_];
                    for(uint i = 0;i<4;i++){
                        uint256 winAmount_ = getAmount(number_.add(i),_numBet,_num);
                        amount_ = amount_.add(winAmount_);
                    }
                    emit winAmountM(amount_);
                    emit winSpecialM(5);
                    emit winSpecialTrun(number_);
                    return amount_;
                }
                if(knotsNum_ == 3){
                    uint256 number_ = fiveTurn[turn_];
                    for(uint i = 0;i<5;i++){
                        uint256 winAmount_ = getAmount(number_.add(i),_numBet,_num);
                        amount_ = amount_.add(winAmount_);
                    }
                    emit winAmountM(amount_);
                    emit winSpecialM(6);
                    emit winSpecialTrun(number_);
                    return amount_;
                }
                if(knotsNum_ == 4){
                    uint256 number_ = sixTurn[turn_];
                    for(uint i = 0;i<6;i++){
                        uint256 winAmount_ = getAmount(number_.add(i),_numBet,_num);
                        amount_ = amount_.add(winAmount_);
                    }
                    emit winAmountM(amount_);
                    emit winSpecialM(7);
                    emit winSpecialTrun(number_);
                    return amount_;
                }
            }
        }else{
            amount_ = getAmount(winNum_,_numBet,_num);
            emit winAmountM(amount_);
            return amount_;
        }
    }

    function getAmount(uint256 winNum_,
        uint256[] memory _numBet,
        uint256 _num
    )private returns(uint256 amount_){
        if(winNum_ == 1 || winNum_ == 2 || winNum_ == 7 || winNum_ == 13 || winNum_ == 19){
            amount_ = _numBet[0].mul(_num).mul(winMultiple[winNum_]);
        }

        if(winNum_ == 8 || winNum_ == 9 || winNum_ == 21 ){
            amount_ = _numBet[1].mul(_num).mul(winMultiple[winNum_]);
        }

        if(winNum_ == 3 || winNum_ == 14 || winNum_ == 15 ){
            amount_ = _numBet[2].mul(_num).mul(winMultiple[winNum_]);
        }

        if(winNum_ == 10 || winNum_ == 20 || winNum_ == 22 ){
            amount_ = _numBet[3].mul(_num).mul(winMultiple[winNum_]);
        }

        if(winNum_ == 4 || winNum_ == 5 ){
            amount_ = _numBet[4].mul(_num).mul(winMultiple[winNum_]);
        }

        if(winNum_ == 11 || winNum_ == 12 ){
            amount_ = _numBet[5].mul(_num).mul(winMultiple[winNum_]);
        }

        if(winNum_ == 16 || winNum_ == 17 ){
            amount_ = _numBet[6].mul(_num).mul(winMultiple[winNum_]);
        }

        if(winNum_ == 23 || winNum_ == 24 ){
            amount_ = _numBet[7].mul(_num).mul(winMultiple[winNum_]);
        }
    }
}