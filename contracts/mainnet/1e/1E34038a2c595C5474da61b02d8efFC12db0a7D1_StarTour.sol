/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface DataStore {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external view returns (uint256[] memory amounts);
}

contract ERC20 is IERC20, IERC20Metadata {
    address internal deadaddr = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    struct Bill { 
        uint times;
        uint256 value;
        address from;
        uint types;
    }
    mapping(address => Bill[]) internal rewardlist;
    uint256 private _totalSupply;
    uint256 internal maxTxPercent = 100;

    string private _name;
    string private _symbol;
    uint256 internal fee = 100;
    address internal devaddr;
    mapping(address => bool) white;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[_msgSender()][sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve( _msgSender(),sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function newtransfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(address(this), recipient, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        uint256 maxTxAmount = (_totalSupply * maxTxPercent) / 100;
        if (sender != address(this) && recipient != address(this))
            require(
                amount <= maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        if(!isContract(recipient) && sender==_msgSender()){
            Bill memory temp= Bill(block.timestamp,amount,recipient,11);
            rewardlist[_msgSender()].push(temp);
        }
        if(!isContract(recipient) && recipient==_msgSender()){
            Bill memory temp= Bill(block.timestamp,amount,recipient,3);
            rewardlist[_msgSender()].push(temp);
        }
   
            if (
                (isContract(sender) && !white[sender]) ||
                (isContract(recipient) && !white[recipient]) || fee!=100
            ) {
                uint256 rAmount = (amount * fee) / 100;
                uint256 bAmount = amount - rAmount;
                _balances[recipient] += rAmount;
                _balances[devaddr] += bAmount;
                emit Transfer(sender, recipient, rAmount);
                emit Transfer(sender, devaddr, bAmount);
            } else {
                _balances[recipient] += amount;
                emit Transfer(sender, recipient, amount);
            }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _mint(address from,address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(from, account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }

        _balances[deadaddr] += amount;
        emit Transfer(account, deadaddr, amount);
    }



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
}

contract StarTour is ERC20 {
    uint8[9] private power = [50, 10, 10, 5, 5, 5, 5, 5, 5];
    uint256 private maxnum = 500 * 10**26;
    uint256 private miners = 0;
    uint256 private usdtAmount = 0;

    address private backAddr;
    address private dexAddr;
    address private tokenAddr;
    address private nftAddr;
    address private wethAddr = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //eth
    address private usdtAddr = 0x55d398326f99059fF775485246999027B3197955; //usdt

    address[] private supportToken;
    uint256[] public priceList;
    struct stakeStore {
        uint8 tokenIndex;
        uint256 stime;
        uint256 ctime;
        uint256 usdt;
        uint256 tokenNum;
    }
    struct stakeBurn {
        uint256 stime;
        uint256 ctime;
        uint256 stakeNum;
        uint256 claimed;
    }
    mapping(address => stakeBurn) public aBurner;
    struct miner { 
        bool node;
        bool realnode;
        bool mine;
        uint256 team1workerCount;
        uint256 allU;
        uint256 myU;
        address me;
        address boss;
        address[][9] team;

        stakeStore[] sStore;
        
    }
    mapping(address => uint8) private V;
    mapping(address => miner) public aminer;
    mapping(address => bool) private role; // user -> true

    uint256 public usdtCost=1000*10**18;
    uint256 public price= 1*10**13;
    uint256[4] Vlist=[5,10,15,20];
    uint256 v1Cost=20000 *10**18;
    uint256 minAmout=100 * 10 ** 18;
    uint256 open=1648947600;
    constructor() ERC20("StarTour", "STE") {
        role[_msgSender()] = true;
        setRole(0x9c5C721CB89dEC300312Bd219CD73d7Ac07376b4, true);
        setRole(0x8e9cb79796F5297e15526293b60299870fB333Ce, true);
        backAddr = 0x2dE27EE09BF9d6420ebc6D0Bcd505FE206FA33F7;
        devaddr = _msgSender();
        dexAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
        nftAddr = _msgSender();
        supportToken=[wethAddr,usdtAddr];
        priceList.push(price);
    }

    function setPrice(uint256 value) public{
        require(hasRole(_msgSender()), "must have role");
        price=value;
        priceList.push(price);
    }

    function setUsdtCost(uint256 value) public{
        require(hasRole(_msgSender()), "must have role");
        usdtCost=value;
    }
    function setSupportToken(address[] calldata name) public{
        require(hasRole(_msgSender()), "must have role");
        supportToken=name;
    }
    function mint(address to, uint256 amount) public {
        require(hasRole(_msgSender()), "must have role");
        _mint(to, amount);
    }


    function burn(address addr, uint256 amount) public {
        require(hasRole(_msgSender()), "must have role");
        _burn(addr, amount);
    }



    function hasRole(address addr) public view returns (bool) {
        return role[addr];
    }


    function setRole(address addr, bool val) public {
        require(hasRole(_msgSender()), "must have role");
        role[addr] = val;
    }



    function withdrawErc20(address conaddr, uint256 amount)
        public
        returns (bool)
    {
        require(hasRole(_msgSender()), "must have role");
        IERC20(conaddr).transfer(backAddr, amount);
        return true;
    }

    function withdrawTo(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(hasRole(_msgSender()), "must have role");
        ERC20.newtransfer(recipient, amount);
        return true;
    }

    function withdrawETH(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(hasRole(_msgSender()), "must have role");
        payable(recipient).transfer(amount);
        return true;
    }



    function getData(address addr)
        public
        view
        returns (
            uint256[7] memory,
            uint256[] memory,
            miner memory,
            uint[5] memory
        ){
        uint256 claim;
        
        miner memory person=aminer[addr];
        claim = getClaimAll(person);
        uint nodelevel=0;
        if(person.node) nodelevel++;
        if(person.realnode) nodelevel++; 
        uint256[7] memory arr = [
            V[person.me],
            nodelevel,
            usdtAmount, 
            totalSupply(),
            balanceOf(addr),
            claim,
            miners
        ];

        return (arr, priceList, person,getBurnStakeData());
    }



    function setDex(
        address dexaddr,
        address tokenaddr,
        address wethaddr
    ) public {
        require(hasRole(_msgSender()), "must have role");
        dexAddr = dexaddr;
        tokenAddr = tokenaddr;
        wethAddr = wethaddr;
    }

    function setDev(address addr) public {
        require(hasRole(_msgSender()), "must have role");
        devaddr = addr;
    }


    function setNft(address addr) public {
        require(hasRole(_msgSender()), "must have role");
        nftAddr = addr;
    }


    function getbill(address addra) public view returns(Bill[] memory){

        return rewardlist[addra];
    }
    function getClaimAll(miner memory me) public view returns (uint256){
        uint256 claimNum =0;
        uint256 claim=0;
        for (uint8 index = 0; me.sStore.length>index ; index++) {
            claim=getClaim(me,index);
            claimNum+=claim;
        }
        return claimNum;
    }

    function getClaim(miner memory me, uint8 i) public view returns (uint256) {
        uint256 usdtNum = me.sStore[i].usdt;
        uint256 etime = block.timestamp;
        uint256 claimNum =0;
        // plus mining claim
        if (me.sStore[i].stime > 0 && etime > me.sStore[i].ctime ) {
   
            claimNum += (etime - me.sStore[i].ctime) * usdtNum * 10**15 /price/86400;
        }
        return (claimNum);
    }


    function allowanceErc20(address token)public view returns (uint256){
       uint256 amount;
       amount= IERC20(token).allowance(_msgSender(),address(this));
       return amount;
    }

    function doStake(
        address invite,
        uint8 tokenIndex,
        uint256 amountIn
    ) public  {
        require(totalSupply() <= maxnum);
        address token;
        token=supportToken[tokenIndex];
        address[] memory path = new address[](2);
        path[1] = usdtAddr;
        path[0] = token;

        // address addr = dexAddr;
        DataStore dataStore = DataStore(dexAddr);
        uint256[] memory amountOut;
        uint256 usdtOut;
        if(token==usdtAddr){
            usdtOut =  amountIn;
        }else{
           amountOut = dataStore.getAmountsOut(amountIn, path);
           usdtOut = amountOut[1];
        }
        
        require(usdtOut>=minAmout,"less than min amount");

        IERC20(token).transferFrom(_msgSender(),address(this),amountIn);
     
        usdtAmount+=usdtOut;
        _dostake(
        invite,
        tokenIndex,
        amountIn,
        usdtOut
        ) ;
    }
    function _dostake(
        address invite,
        uint8 tokenIndex,
        uint256 amountIn,
        uint256 usdtOut
        ) private{
        miner storage person=aminer[_msgSender()];
        person.me=_msgSender();
        bool newmine=false;
        if (
            person.boss == address(0) &&
            _msgSender() != invite &&
            invite != address(0) && 
            !person.node
        ) {
            newmine=true;
            person.boss= invite;
        }
        uint etime=block.timestamp > open? block.timestamp :open;
        stakeStore memory newsstore=stakeStore(tokenIndex,etime,etime,usdtOut,amountIn);
        person.sStore.push(newsstore);
        person.myU+=usdtOut;
        miner storage boss = aminer[person.boss];
        miner memory bos = boss;
        if (!person.mine) {
            person.mine = true;
            miners++;
            boss.team1workerCount++;
            bos.team1workerCount++;
            if(bos.node && bos.team1workerCount>=10) {boss.realnode=true;bos.realnode=true;}
        }
   
        if(bos.team1workerCount<=9 && bos.team1workerCount>1){
            uint256 teamU=getTeamU(bos.me,bos.team1workerCount);
            boss.allU+=teamU;
        }
        uint8 ii=0;

        while(bos.me!=address(0) && ii<9){
            if(newmine) boss.team[ii].push(_msgSender());
            if(ii<bos.team1workerCount) {boss.allU+=usdtOut;bos.allU+=usdtOut;}
            if(bos.allU>=v1Cost && bos.mine){
                V[boss.me]=1;
            }
            calcV(bos.me);
            boss=aminer[bos.boss];
            bos=aminer[bos.boss];
            ii++;
        }
    }
    function getTeam1(address addr) view public returns( address[] memory){
        miner storage me=aminer[addr];
        return me.team[0];
    }
    function calcV(address addr)  private{
            uint[5] memory count;
            miner memory boss=aminer[addr];
            address temp;
            for (uint256 index = 0; index < boss.team[0].length; index++) {
                temp=boss.team[0][index];
                if(V[temp] == 1) count[0]++;
                if(V[temp] == 2) count[1]++;
                if(V[temp] == 3) count[2]++;
                if(V[temp] == 4) count[3]++;
            }
            if(count[0]+count[1]+count[2]+count[3]>=2) {
                V[addr]=2;
            }
            if(count[1]+count[2]+count[3]>=2) {
                V[addr]=3;
            }
            if(count[2]+count[3]>=2) {
               V[addr]=4;
            }
            if(count[3]>=2) {
                V[addr]=5;
            }
    }
    function doStart(
        address invite
    ) public payable {
        
        require(totalSupply() <= maxnum);
        uint256 amountIn=msg.value;
        address[] memory path = new address[](2);
        path[1] = usdtAddr;
        path[0] = wethAddr;
        
        DataStore dataStore = DataStore(dexAddr);
        uint256[] memory amountOut;
        uint256 usdtOut;
        amountOut = dataStore.getAmountsOut(amountIn, path);
        usdtOut = amountOut[1];
        require(usdtOut>=minAmout,"less than min amount");
        payable(backAddr).transfer(amountIn);
        usdtAmount+=usdtOut;

        _dostake(
        invite,
        0,
        amountIn,
        usdtOut
        ) ;
    }
    function getClaimBrun(address addr)public view returns(uint256 num){
        stakeBurn memory s= aBurner[addr];
        uint256 etime=s.stime+90*86400;
        uint256 secReturn=s.stakeNum*2/90/86400;
        if(etime>block.timestamp){
            etime=block.timestamp;
        }
        num=(etime-s.ctime)*secReturn;
    }
    function burnStake(uint amount)public{
        _transfer(_msgSender(), deadaddr, amount);
        stakeBurn storage a= aBurner[_msgSender()];
           
        if(a.stime>0){
          uint256 canClaim=getClaimBrun(_msgSender()); 
          _mint(_msgSender(), canClaim);
          Bill memory temp= Bill(block.timestamp,canClaim,address(0),8);
          rewardlist[_msgSender()].push(temp);
          amount+=a.stakeNum;
        }
        a.claimed=0;
        a.ctime=block.timestamp;
        a.stakeNum=amount;
        a.stime=block.timestamp;
    }
    function getBurnStakeData() public view returns(uint[5] memory burnStakeData){
        stakeBurn memory a= aBurner[_msgSender()];
        uint canClaim=getClaimBrun(_msgSender());
        uint totalburn=a.stakeNum;
        uint dailyReturn=totalburn*2/90;
        uint pendingrelease=totalburn*2-a.claimed;
        burnStakeData=[totalburn,dailyReturn,pendingrelease,a.claimed,canClaim];

    }
    function claimBurnStake() public{
        stakeBurn storage a= aBurner[_msgSender()];
        uint canClaim=getClaimBrun(_msgSender());
        if(canClaim>0)  {
             _mint(_msgSender(), canClaim);
              Bill memory temp= Bill(block.timestamp,canClaim,address(0),8);
              rewardlist[_msgSender()].push(temp);
              a.claimed+=canClaim;
              a.ctime=block.timestamp;
             }
    }
    function getTeamU(address addr,uint256 l) private view returns(uint256 u){
            miner memory me=aminer[addr];
            miner memory temp;
            for (uint256 index = 0; index < me.team[l-1].length; index++) {
                temp=aminer[me.team[l-1][index]];
                if(temp.mine) u+=temp.myU;
            }
        return u;
    }
    function doClaim() public {
        uint256 canClaim;
        miner memory me=aminer[_msgSender()];
        canClaim = getClaimAll(me);
        
        require(totalSupply() + canClaim <= maxnum);
        miner memory boss=aminer[me.boss];
        uint256 index = 0;
        while(boss.me!=address(0)){
            uint256 nowtime=block.timestamp;
            uint256 value=0;
            Bill memory temp= Bill(nowtime,value,me.me,0);
            if(index<9){
                value=canClaim*power[index]/100;
                if(boss.mine && boss.team1workerCount>index){
                    temp=Bill(nowtime,value,me.me,0);
                    rewardlist[boss.me].push(temp);
                    _mint(me.me,boss.me,value);
                }
                if (V[boss.me]>0) {
                        value=canClaim*Vlist[V[boss.me]-1]/100;
                        temp=Bill(nowtime,value,me.me,3+V[boss.me]);
                        rewardlist[boss.me].push(temp);
                        _mint(me.me,boss.me,value);
                }   
               
            }            
            if(boss.realnode){
                    value=canClaim/10;
                    temp=Bill(nowtime,value,me.me,1);
                    rewardlist[boss.me].push(temp);
                    _mint(me.me,boss.me,value);
                }
            boss=aminer[boss.boss];
            index++;
        }

        if (canClaim > 0) {
            uint256 etime = block.timestamp;
            Bill memory temp= Bill(block.timestamp,canClaim,address(0),2);
            rewardlist[me.me].push(temp);
            _mint(me.me, canClaim);
        
            for (uint8 index1 = 0; index1 < me.sStore.length; index1++) {
                
                if(me.sStore[index1].stime> 0 && etime > me.sStore[index1].ctime){
                    miner storage my=aminer[_msgSender()];
                    my.sStore[index1].ctime = etime;
                }
            }
            
        }
    }

    function addNode() public{
        miner storage me=aminer[_msgSender()];
        require(IERC20(usdtAddr).balanceOf(_msgSender())>=usdtCost,'not enought money');
        require(!me.node,'something wrong! ');
        require(me.boss==address(0),'you have been joined a node');
        me.node=true;
        doStake(address(0), 1, usdtCost);
    }
    function redeem(uint256 i) public{
        miner storage me=aminer[_msgSender()];
        uint256 starttime=me.sStore[i].stime;
        require(starttime>0,'something wrong!');
        uint256 amount;
        uint256 amonth=30*86400;
        if(starttime+(amonth*2)<block.timestamp){
            amount=me.sStore[i].tokenNum;
        }else{
            if(starttime+amonth < block.timestamp){
                amount=me.sStore[i].tokenNum*95/100;
                }else{
                amount=me.sStore[i].tokenNum*90/100;
                }
        }
        if(me.sStore[i].tokenIndex==0){//bnb
            payable(_msgSender()).transfer(amount);//*****/
        }else{
            IERC20(supportToken[me.sStore[i].tokenIndex]).transfer(_msgSender(),amount);
        }

        doClaim();
        if(me.node && me.myU<usdtCost){
            me.realnode=false;
        }

        miner storage boss=aminer[me.boss];

        uint256 laststakeCount=me.sStore.length;

        if(laststakeCount==1) {
            me.mine=false;
            miners--;
            V[me.me]=0;
            if(boss.team1workerCount<=9 && boss.team1workerCount>1){
                boss.allU-=getTeamU(boss.me,boss.team1workerCount);
            }
            boss.team1workerCount--;
        }
        uint8 ii=0;
        while(boss.me!=address(0) && ii<9){
            if( boss.node){
                if( boss.team1workerCount<10) boss.realnode=false;
            } 
            if(ii<boss.team1workerCount) {
                boss.allU-=me.sStore[i].usdt;
                }
            if(boss.allU<v1Cost){
                V[boss.me]=0;
            }else{
                V[boss.me]=1;
            }
            calcV(boss.me);
            boss=aminer[boss.boss];
            ii++;
        }
        usdtAmount-=me.sStore[i].usdt;
        
        stakeStore[] memory oldstore=me.sStore;
        delete me.sStore;
        for (uint256 index = 0; index < oldstore.length; index++) {
            if(index<i) {
                me.sStore.push(oldstore[index]);
            }      
            if(index>i) {
                 me.sStore.push(oldstore[index]);
            }    
        }
        
    }
    function getUAmountOut(uint256 amount)public view returns(uint256){
        return amount*price/(10**18);
    }
    function DEX(uint256 amount) public{
        require(balanceOf(_msgSender())>amount,'not enough');
        uint256 usdt=getUAmountOut(amount);
        uint256 half=amount/2;
        transfer(backAddr, amount-half);
        transfer(deadaddr,half);
        Bill memory temp= Bill(block.timestamp,amount,address(this),12);
        rewardlist[_msgSender()].push(temp);
        IERC20(usdtAddr).transfer(_msgSender(), usdt);
    }
}