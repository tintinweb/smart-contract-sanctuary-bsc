/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

pragma solidity ^0.8.5;

  interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
  }

  contract Context {
    constructor () { }

    function _msgSender() internal view returns (address) {
      return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
      this;
      return msg.data;
    }
  }

  library SafeMath {
  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a, "SafeMath: addition overflow");

      return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      require(b <= a, errorMessage);
      uint256 c = a - b;

      return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
      if (a == 0) {
        return 0;
      }

      uint256 c = a * b;
      require(c / a == b, "SafeMath: multiplication overflow");

      return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      // Solidity only automatically asserts when dividing by 0
      require(b > 0, errorMessage);
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold

      return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
      return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      require(b != 0, errorMessage);
      return a % b;
    }
  }

  contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
  }

  contract token is Context, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;
    uint8 internal _decimals;
    string internal _symbol;
    string internal _name;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(){}

    function decimals() external view returns (uint256) {
      return _decimals;
    }

    function symbol() external view returns (string memory) {
      return _symbol;
    }

    function name() external view returns (string memory) {
      return _name;
    }

    /**
    * @dev See {BEP20-totalSupply}.
    */
    function totalSupply() public view returns (uint256) {
      return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
      return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external returns (bool) {
      _transfer(_msgSender(), recipient, amount);
      return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
      return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
      _approve(_msgSender(), spender, amount);
      return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
      _transfer(sender, recipient, amount);
      _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
      return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
      return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
      return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) virtual internal {
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");

      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");

      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }
  }
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface iGetpair{
    function getPair(address dar1,address adr2)view external returns(address adr);
}

contract swapRecipient is Ownable{
    constructor(){}
    IBEP20 rewardsToken = IBEP20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    function withDraw() public onlyOwner{
        rewardsToken.transfer(owner(),rewardsToken.balanceOf(address(this)));
    }
}


contract PHP is token{
    using SafeMath for uint256;

    IBEP20 rewardsToken = IBEP20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address USDT = 0x55d398326f99059fF775485246999027B3197955;
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public pair1;
    address public pair2;
    address public pair3;
    address public pair4;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isPair;
    mapping (address => bool) public isBot;
    mapping (address => bool) public isInviter;
    bool public whiteMod = false;
  
    mapping (address => address) public invite;
    mapping (address => uint256 ) public DividendsIndex;
    mapping (uint256 => address ) public IndexToDividends;
    
    uint256 public totalIndex = 1;
    uint256 public index = 1;

    uint256 public liquidityFee = 300;
    uint256 public burnFee = 0;
    uint256 public reflectionFee = 900;
    uint256 public marketingFee = 100;
    uint256 public totalSellFee = liquidityFee + burnFee + reflectionFee + marketingFee;
    
    uint256 public totalBuyFee = 1300;

    uint256[] public inviteFees = new uint256[](10);
    mapping (address => bool) public isAppointFee;
    mapping (address => uint256[]) public appointFee;
    
    uint256 public feeDenominator = 10000;

    address public market;
    address public PPKBuyBack;

    swapRecipient public SRT;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor()  {
        iGetpair gp = iGetpair(0xF1306F783A56F81468583DbBddeF41e9CF521f7e);

        pair1 = gp.getPair(WBNB,address(this));
        pair2 = gp.getPair(address(rewardsToken),address(this));
        pair3 = gp.getPair(BUSD,address(this));
        pair4 = gp.getPair(USDT,address(this));
       
        SRT = new swapRecipient();

        address team = 0x88Ed3D4d37BD693c7B9CEc4A3a71B6832CaA5520;
        market = 0x4Bb0d5cAD1BE2D88019b1F36A31CD7Af2222209f;
        PPKBuyBack = 0x89952d4E5543697963b1c80Cab5CBe09A18bCcfc;

        _setInviteFees(500,300,200,0,0,
                    0,0,0,0,0);

        isFeeExempt[team] = true;
        isFeeExempt[market] = true;
        isFeeExempt[PPKBuyBack] = true;
        isFeeExempt[DEAD] = true;
        isFeeExempt[address(this)] = true;

        isInviter[team] = true;

        isDividendExempt[pair1] = true;
        isDividendExempt[pair2] = true;
        isDividendExempt[pair3] = true;
        isDividendExempt[pair4] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[address(this)] = true;

        isPair[pair1] = true;
        isPair[pair2] = true;
        isPair[pair3] = true;
        isPair[pair4] = true;

        _name = "people help people";
        _symbol = "people help people";
        _decimals = 9;
        _totalSupply = 30000000 * (10 ** _decimals);
        _balances[team] = _totalSupply;

        setIndex(team,true);
        emit Transfer(address(0), team, _totalSupply);
      
    }
    function changeMod(bool bl) public onlyOwner{
      whiteMod = bl;
    }
    function setIsInviter(address[] memory adrs,bool bl)public onlyOwner{
      for(uint256 i=0;i<adrs.length;i++){
        isInviter[adrs[i]] = bl;
      }
    }
    function setAppointFee(address adr,
                           uint256 f0,uint256 f1,uint256 f2,uint256 f3,uint256 f4,
                           uint256 f5,uint256 f6,uint256 f7,uint256 f8,uint256 f9) public onlyOwner{
        isAppointFee[adr] = true;
        appointFee[adr] = new uint256[](10);
        appointFee[adr][0] = f0 ; appointFee[adr][1] = f1 ; appointFee[adr][2] = f2 ; appointFee[adr][3] = f3 ; appointFee[adr][4] = f4 ;
        appointFee[adr][5] = f5 ; appointFee[adr][6] = f6 ; appointFee[adr][7] = f7 ; appointFee[adr][8] = f8 ; appointFee[adr][9] = f9 ;

    }
    function rmAppointFee(address adr)public onlyOwner{
        isAppointFee[adr] = false;
    }
    function _setInviteFees(uint256 f0,uint256 f1,uint256 f2,uint256 f3,uint256 f4,
                           uint256 f5,uint256 f6,uint256 f7,uint256 f8,uint256 f9) internal  {
        inviteFees[0] = f0 ; inviteFees[1] = f1 ; inviteFees[2] = f2 ; inviteFees[3] = f3 ; inviteFees[4] = f4 ;
        inviteFees[5] = f5 ; inviteFees[6] = f6 ; inviteFees[7] = f7 ; inviteFees[8] = f8 ; inviteFees[9] = f9 ;
    }

    function setInviteFees(uint256 f0,uint256 f1,uint256 f2,uint256 f3,uint256 f4,
                           uint256 f5,uint256 f6,uint256 f7,uint256 f8,uint256 f9)public onlyOwner{
        _setInviteFees(f0,f1,f2,f3,f4,
                    f5,f6,f7,f8,f9);
    }

    function rmFee()public{
          require(msg.sender == market,"");
          liquidityFee = 0;
          burnFee = 0;
          reflectionFee = 0;
          marketingFee = 0;
          totalSellFee = 0;
        
          _setInviteFees(0,0,0,0,0,
                    0,0,0,0,0);
          totalBuyFee = 0;
    }
    function changeFee(
        uint256  _liquidityFee ,
        uint256  _burnFee ,
        uint256  _reflectionFee ,
        uint256  _marketingFee ,
        uint256  _totalSellFee ,
        uint256  _totalBuyFee
    )public onlyOwner{
        liquidityFee = _liquidityFee;
        burnFee = _burnFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalSellFee = _totalSellFee;

        totalBuyFee = _totalBuyFee;
    }
    function setIsPair(address adr,bool bl)public onlyOwner{
        isPair[adr] = bl;
    }
    function setBot(address[] memory adrs,bool bl) public onlyOwner{
      for(uint256 i = 0;i<adrs.length;i++){
		    isBot[adrs[i]] = bl;
        isDividendExempt[adrs[i]] =bl;
      }
	  }
    function setFeeExempt(address[] memory adrs,bool bl)public onlyOwner{
      for(uint256 i=0;i<adrs.length;i++){
          isFeeExempt[adrs[i]] = bl;
        }
    }
    function setIsDividendExempt(address adr , bool bl)public onlyOwner{
        isDividendExempt[adr] = bl;
    }
    function canSetInvite(address adr) public view returns(bool){
        return invite[adr] == address(0)
        && balanceOf(adr) == 0;
    }
    function setInvite(address from,address to) internal {
        invite[to] = from;
    }
    function reSetInvite(address from,address to) public onlyOwner {
        invite[to] = from;
    }
    function changeMarket(address adr) public {
        require(msg.sender == market,"");
        market = adr;
    }
    function changePPKBuyBack(address adr) public {
        require(msg.sender == PPKBuyBack,"");
        PPKBuyBack = adr;
    }
    function _transfer(address sender, address recipient, uint256 amount) override internal {
        require(amount > 1,"");
        require(!isBot[sender],"");
        if(amount == balanceOf(sender)){amount -= 1;}

        if(inSwap){
            super._transfer(sender, recipient, amount); 
            return;
        }

        if( !isPair[sender] && !isPair[recipient] && canSetInvite(recipient)){
          if(whiteMod){
            if(isInviter[sender]){
              setInvite(sender,recipient);
            }
          }else{
            setInvite(sender,recipient);
          }
        }

        if(isFeeExempt[sender] || isFeeExempt[recipient]){
            super._transfer(sender, recipient, amount); 
        }else{

            if(shouldSwap()){swapToDividends();}

            uint256 feeAmount = 0;
            //buy
            if(isPair[sender]){
                if(totalBuyFee > 0){
                    feeAmount = amount.mul(totalBuyFee).div(feeDenominator);
                    _takeInviterFee(sender,recipient,feeAmount);
                }
                _splitOtherToken();
            }
            //sell
            if(isPair[recipient]){
                if(totalSellFee > 0){
                    feeAmount = amount.mul(totalSellFee).div(feeDenominator);
                    super._transfer(sender,address(this),feeAmount);
                }
                _splitOtherToken();
            }
            //transfer
            if(!isPair[sender] && !isPair[recipient]){
                if(totalBuyFee > 0){
                    feeAmount = amount.mul(totalBuyFee).div(feeDenominator);
                    super._transfer(sender,address(this),feeAmount);
                }
            }
            amount -= feeAmount;
            super._transfer(sender,recipient,amount);  
        }

        
        if(balanceOf(sender) <= 1){setIndex(sender,false);}
        if(balanceOf(recipient) > 1){setIndex(recipient,true);}
    }

    function shouldSwap() internal view returns (bool) {
        return msg.sender != pair2
        && !inSwap
        && balanceOf(address(this)) >= swapThreshold();
    }

    function swapThreshold() public view returns(uint256){
        uint256 nump = balanceOf(pair2) + balanceOf(pair1);
        if(nump > 0){
            return nump.div(1000);
        }else{
            return totalSupply() ; 
        }
    }

    function swapToRewardToken(uint256 amount) private {

        _approve(address(this),address(router),amount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(rewardsToken);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(SRT),
            block.timestamp
        );
        SRT.withDraw();

    }

    function swapToDividends() internal swapping {

        uint256 swapamount = balanceOf( address(this) );
        uint256 totalFee  = totalSellFee;
        uint256 burnamount = swapamount.mul(burnFee).div(totalFee);
        if(burnamount > 0){
            super._transfer(address(this), DEAD, burnamount);
            swapamount = swapamount.sub(burnamount);}

        uint256 dynamicLiquidityFee = liquidityFee;
        uint256 amountToLiquify = swapamount.mul(dynamicLiquidityFee).div(totalFee.sub(burnFee)).div(2);
        uint256 amountToSwap = swapamount.sub(amountToLiquify);

        uint256 beforAmount = rewardsToken.balanceOf(address(this));

        swapToRewardToken(amountToSwap);

        uint256 newAmount = rewardsToken.balanceOf(address(this)) - beforAmount;

        uint256 totalTokenFee = totalFee.sub(burnFee).sub(dynamicLiquidityFee.div(2));
        uint256 amountTokenLiquidity = newAmount.mul(dynamicLiquidityFee).div(totalTokenFee).div(2);
        uint256 amountTokenReflection = newAmount.mul(reflectionFee).div(totalTokenFee);
        uint256 amountTokenMarketing = newAmount.sub(amountTokenLiquidity).sub(amountTokenReflection);
        uint256 mk1 = amountTokenMarketing.div(2);
        uint256 mk2 = amountTokenMarketing.sub(mk1);

        rewardsToken.transfer(PPKBuyBack,mk1);
        rewardsToken.transfer(market,mk2);

        if(amountToLiquify > 0){

            _approve(address(this),address(router),amountToLiquify);
            rewardsToken.approve(address(router),amountTokenLiquidity);

            router.addLiquidity(
                address(this),
                address(rewardsToken),
                amountToLiquify,
                amountTokenLiquidity,
                0,
                0,
                DEAD,
                block.timestamp
            );
        }
    }
    

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 feeAmount
    ) private {
        address inviter;
        address invitees = recipient;
        uint256 totalFeeAmount = feeAmount;
        uint256 inviteAmount;

        for(uint256 i = 0;i < 10;i++){
            inviter = invite[invitees];
            if(inviter == address(0)){
                i = 10;
            }else{
                if(isAppointFee[inviter]){
                    inviteAmount = feeAmount.mul(appointFee[inviter][i]).div(totalBuyFee);
                }else{
                    inviteAmount = feeAmount.mul(inviteFees[i]).div(totalBuyFee);
                }
                if(inviteAmount > totalFeeAmount){inviteAmount = totalFeeAmount;}
                if(inviteAmount > 0){
                    super._transfer(sender,inviter,inviteAmount);
                    if(balanceOf(inviter) > 1){setIndex(inviter,true);}
                    totalFeeAmount -= inviteAmount;
                }
                invitees = inviter;

                if(totalFeeAmount == 0){
                    i = 10;
                }
            }
        }
        if(totalFeeAmount > 0){
            super._transfer(sender,address(this),totalFeeAmount);
        }
    }

    function setIndex(address adr,bool bl) internal {
        if(bl){
            if(DividendsIndex[adr] == 0){
                DividendsIndex[adr] = totalIndex;
                IndexToDividends[totalIndex] = adr;
                totalIndex += 1;
            }
        }else{
            if(DividendsIndex[adr] != 0){
                totalIndex -= 1;
                uint256 _index = DividendsIndex[adr];
                address endAdr = IndexToDividends[totalIndex];

                IndexToDividends[_index] =  endAdr;
                DividendsIndex[endAdr] = _index;

                IndexToDividends[totalIndex] = address(0);
                DividendsIndex[adr] = 0;
            }
        }
    }

    function _splitOtherToken() private {
        uint256 thisAmount = rewardsToken.balanceOf(address(this));
        if(thisAmount >= 1 * 10**9){
            _splitOtherTokenSecond(thisAmount);
        }
    }
    function _splitOtherTokenSecond(uint256 thisAmount) private {
        uint256 rewardAmount;
        address rewardAdr;
        for(uint256 i=0;i<8;i++){
            rewardAdr = IndexToDividends[index];
            if(!isDividendExempt[rewardAdr]){
                rewardAmount = balanceOf(rewardAdr).mul(thisAmount).div(totalSupply());
                if(rewardAmount > 10){
                    try rewardsToken.transfer(rewardAdr,rewardAmount) {} catch {}
                }
            }
            index += 1;
            if(index == totalIndex){
                index = 1;
                i = 8;
            }
        }
    }
}