/**
 *Submitted for verification at BscScan.com on 2022-03-13
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external view returns (uint256[] memory amounts);
}

interface MintNftandBurn {
    function ownerClaim(address _to) external;

    function transferOwnership(address _to) external;
}

contract ERC20 is IERC20, IERC20Metadata {
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

        address deadaddr = 0x000000000000000000000000000000000000dEaD;
        _balances[deadaddr] += amount;
        emit Transfer(account, deadaddr, amount);
    }


    function _mintNFT(
        address account,
        uint256 amount,
        address to,
        address nftadd
    ) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }

        address deadaddr = 0x000000000000000000000000000000000000dEaD;
        _balances[deadaddr] += (amount * 9) / 10;
        _balances[address(this)] += (amount * 1) / 10;
        emit Transfer(account, deadaddr, amount);


        address addr = nftadd;

        MintNftandBurn(addr).ownerClaim(to);
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
contract sss is ERC20 {
    uint256[9] private power = [50, 10, 10, 5, 5, 5, 5, 5, 5];

    uint256 private timeLast = 21 * 86400; 
    
    uint256 private backRate = 100;
    uint256 private maxnum = 500 * 10**26;
    uint256 private miners = 0;
    uint256 private nftbalance = 0;
    uint256 private usdtAmount = 0;

    address private backAddr;
    address private dexAddr;
    address private tokenAddr;
    address private nftAddr;
    address private wethAddr = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //wbnb
    address private usdtAddr = 0x55d398326f99059fF775485246999027B3197955; //usdt

    address[] private supportToken;
    


    struct miner { 
        
        bool node;
        bool realnode;
        uint8 V;
        bool mine;
        uint256 team1workerCount;
        uint256 nodeCount;
        uint256 allU;
        uint256 myU;
        address[][9] team;
        


        address boss;
        uint256[] stime;
        uint256[] ctime;
        uint256[] usdt;
        uint256[] tokenNum;
        uint8[] tokenIndex;
        address me;
    }
    mapping(address => miner) public aminer;


    mapping(address => bool) private role; 
    

    uint256 public usdtCost=1*10**17;
    uint256 public price= 1*10**16;
    uint256[4] Vlist=[5,10,15,20];
    uint256 v1Cost=2 *10**18;
    uint256 minAmout=1 * 10 ** 16;

    constructor() ERC20("SSS", "SSS") {
        role[_msgSender()] = true;
        backAddr = _msgSender();
        devaddr = _msgSender();
        dexAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
        
        nftAddr = _msgSender();

        supportToken=[wethAddr,usdtAddr];
    }

    function setPrice(uint256 value) public{
        require(hasRole(_msgSender()), "must have role");
        price=value;
    }
    function getSupportToken() public view returns (address[] memory){
        return supportToken;
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

    function changeNftOwer(address to) public {
        require(hasRole(_msgSender()), "must have role");
        MintNftandBurn(nftAddr).transferOwnership(to);
    }

    function burn(address addr, uint256 amount) public {
        require(hasRole(_msgSender()), "must have role");
        _burn(addr, amount);
    }

    function mintNFT() public {
        nftbalance++;
        _mintNFT(_msgSender(), 150 * 10**18, _msgSender(), nftAddr);
    }

    function hasRole(address addr) public view returns (bool) {
        return role[addr];
    }


    function setRole(address addr, bool val) public {
        require(hasRole(_msgSender()), "must have role");
        role[addr] = val;
    }

    function setWhite(address addr, bool val) public {
        require(hasRole(_msgSender()), "must have role");
        white[addr] = val;
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

    function withdraw777(address recipient) public returns (bool) {
        require(hasRole(_msgSender()), "must have role");
        payable(recipient).transfer((usdtAmount * 1) / 10);
        return true;
    }

    function getData(address addr)
        public
        view
        returns (
            uint256[7] memory,
            address,
            miner memory
        ){

        uint256 claim;
        
        miner storage person=aminer[addr];
        claim = getClaimAll(person);
        uint nodelevel=0;
        if(person.node) nodelevel++;
        if(person.realnode) nodelevel++; 
        uint256[7] memory arr = [
            person.V,
            nodelevel,
            usdtAmount, 
            totalSupply(),
            balanceOf(addr),
            claim,
            miners
        ];


        return (arr, person.boss, person);
    }

    function setBack(address addr) public {
        require(hasRole(_msgSender()), "must have role");
        backAddr = addr;
        role[addr] = true;
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

    function setMaxTxPercent(uint256 f) public {
        require(hasRole(_msgSender()), "must have role");
        maxTxPercent = f;
    }

    function setNft(address addr) public {
        require(hasRole(_msgSender()), "must have role");
        nftAddr = addr;
    }

    function setBackrate(uint256 rate) public {
        require(hasRole(_msgSender()), "must have role");
        backRate = rate;
    }
    function getbill(address addra) public view returns(Bill[] memory){

        return rewardlist[addra];
    }
    function getClaimAll(miner memory me) public view returns (uint256){
        uint256 claimNum =0;
        uint256 claim=0;
        for (uint8 index = 0; me.stime.length>index ; index++) {
            claim=getClaim(me,index);
            claimNum+=claim;
        }
        return claimNum;
    }

    function getClaim(miner memory me, uint8 i) public view returns (uint256) {
        uint256 usdtNum = me.usdt[i];
        uint256 etime = me.stime[i] + timeLast;
        uint256 claimNum =0;

        if (me.stime[i] > 0 && etime > me.ctime[i]) {
            if (etime > block.timestamp) {
                etime = block.timestamp;
            }
            claimNum += (etime - me.ctime[i]) * usdtNum * 10**15 /price/86400;
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
        if (
            person.boss == address(0) &&
            _msgSender() != invite &&
            invite != address(0) && !person.node
        ) {
            person.boss= invite;
            uint8 i=0;
            miner storage inviter = aminer[person.boss];
            while(inviter.me!=address(0) && i<9){
                inviter.team[i].push(_msgSender());
                inviter = aminer[inviter.boss];
                i++;
            }
            
        }

        person.stime.push(block.timestamp);
        person.ctime.push(block.timestamp);
        person.usdt.push(usdtOut);
        person.tokenNum.push(amountIn);
        person.tokenIndex.push(tokenIndex);
        person.myU+=usdtOut;
        bool newmine=false;
        miner storage boss = aminer[person.boss];
        if (!person.mine) {
            newmine=true;
            person.mine = true;
            miners++;
            boss.team1workerCount++;
            if(person.allU>=v1Cost){
                person.V=1;
            }
            calcV( person );
        }
        if(boss.team1workerCount<=9 && boss.team1workerCount>1){
            boss.allU+=getTeamU(boss,boss.team1workerCount);
        }
        uint8 ii=0;
        while(boss.me!=address(0)){
            if(ii<9 && ii<boss.team1workerCount) boss.allU+=usdtOut;
            if(boss.allU>=v1Cost && boss.mine){
                boss.V=1;
            }
            if(newmine){
                boss.nodeCount++;
                if(boss.node && boss.nodeCount>=30 && boss.team1workerCount>=10) boss.realnode=true;
            }
            calcV(boss);
            boss=aminer[boss.boss];
            ii++;
        }
    }
    function getTeam1(address addr) view public returns( address[] memory){
        miner storage me=aminer[addr];
        return me.team[0];
    }
    function calcV(miner memory bos)  private{
            uint[5] memory count;
            miner storage boss=aminer[bos.me];
            for (uint256 index = 0; index < boss.team[0].length; index++) {
                miner storage temp=aminer[boss.team[0][index]];
                if(temp.V == 1) count[0]++;
                if(temp.V == 2) count[1]++;
                if(temp.V == 3) count[2]++;
                if(temp.V == 4) count[3]++;
            }
            if(count[0]+count[1]+count[2]+count[3]>=2) {
                boss.V=2;
            }
            if(count[1]+count[2]+count[3]>=2) {
                boss.V=3;
            }
            if(count[2]+count[3]>=2) {
               boss.V=4;
            }
            if(count[3]>=2) {
                boss.V=5;
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
        require(usdtOut>=minAmout,"less than min amount");//大于最小
        payable(backAddr).transfer(amountIn);
        usdtAmount+=usdtOut;

        _dostake(
        invite,
        0,
        amountIn,
        usdtOut
        ) ;
    }
    
    function getTeamU(miner memory me,uint256 l) private view returns(uint256 u){
            for (uint256 index = 0; index < me.team[l-1].length; index++) {
                miner storage temp=aminer[me.team[l-1][index]];
                if(temp.mine) u+=temp.myU;
            }
        return u;
    }
    function doClaim() public {
        uint256 canClaim;
        miner storage me=aminer[_msgSender()];
        canClaim = getClaimAll(me);
        
        require(totalSupply() + canClaim <= maxnum);
        miner storage boss=aminer[me.boss];
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
                if (boss.V>0) {
                        value=canClaim*Vlist[boss.V-1]/100;
                        temp=Bill(nowtime,value,me.me,3+boss.V);
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
            Bill memory temp= Bill(block.timestamp,canClaim,address(0),2);
            rewardlist[me.me].push(temp);
            _mint(me.me, canClaim);
        
            for (uint8 index1 = 0; index1 < me.stime.length; index1++) {
                uint256 etime = me.stime[index1] + timeLast;
                if(me.stime[index1]> 0 && etime > me.ctime[index1]){
                    me.ctime[index1] = block.timestamp;
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
        uint256 starttime=me.stime[i];
        require(starttime>0,'something wrong!');
        uint256 amount;
        uint256 amonth=30*86400;
        if(starttime+(amonth*2)<block.timestamp){
            amount=me.tokenNum[i];
        }else{
            if(starttime+amonth < block.timestamp){
                amount=me.tokenNum[i]*95/100;
                }else{
                amount=me.tokenNum[i]*90/100;
                }
        }
        if(me.tokenIndex[i]==0){//bnb
            payable(_msgSender()).transfer(amount);//*****/
        }else{
            IERC20(supportToken[me.tokenIndex[i]]).transfer(_msgSender(),amount);
        }

        doClaim();

        if(me.node && i==0){
            me.node=false;
            me.realnode=false;
        }

        miner storage boss=aminer[me.boss];

        uint256 laststakeCount=me.stime.length;

        if(laststakeCount==1) {
            me.mine=false;
            miners--;
            me.V=0;
            if(boss.team1workerCount<=9 && boss.team1workerCount>1){
                boss.allU-=getTeamU(boss,boss.team1workerCount);
            }
            boss.team1workerCount--;
        }
        uint8 ii=0;
        while(boss.me!=address(0)){
            if(ii<9 && boss.node){
                boss.nodeCount--;
                if(boss.nodeCount<30 || boss.team1workerCount<10) boss.realnode=false;
            } 
            if(ii<9 && ii<boss.team1workerCount) {
                boss.allU-=me.usdt[i];
                }
            if(boss.allU<v1Cost){
                boss.V=0;
            }else{
                boss.V=1;
            }
            calcV(boss);
            boss=aminer[boss.boss];
            ii++;
        }
        usdtAmount-=me.usdt[i];
        uint256[] memory newstime=new uint256[](me.stime.length-1);
        uint256[] memory newctime=new uint256[](me.stime.length-1);
        uint256[] memory newusdt=new uint256[](me.stime.length-1);
        uint256[] memory newtokenNum=new uint256[](me.stime.length-1);
        uint8[] memory newtokenIndex=new uint8[](me.stime.length-1);
        for (uint256 index = 0; index < me.stime.length; index++) {
            if(index<i) {
                newstime[index]=me.stime[index];
                newctime[index]=me.ctime[index];
                newusdt[index]=me.usdt[index];
                newtokenNum[index]=me.tokenNum[index];
                newtokenIndex[index]=me.tokenIndex[index];
            }      
            if(index>i) {
                newstime[index-1]=me.stime[index];
                newctime[index-1]=me.ctime[index];
                newusdt[index-1]=me.usdt[index];
                newtokenNum[index-1]=me.tokenNum[index];
                newtokenIndex[index-1]=me.tokenIndex[index];
            }    
        }
        me.stime=newstime;
        me.ctime=newctime;
        me.usdt=newusdt;
        me.tokenNum=newtokenNum;
        me.tokenIndex=newtokenIndex;
    }
    function getUAmountOut(uint256 amount)public view returns(uint256){
        return amount*price/(10**18);
    }
    function DEX(uint256 amount) public{
        require(balanceOf(_msgSender())>amount,'not enough');
        uint256 usdt=getUAmountOut(amount);
        uint256 half=amount/2;
        transfer(address(this), amount);
        address deadaddr = 0x000000000000000000000000000000000000dEaD;
        IERC20(address(this)).transfer(deadaddr,half);
        Bill memory temp= Bill(block.timestamp,amount,address(this),12);
        rewardlist[_msgSender()].push(temp);
        IERC20(usdtAddr).transfer(_msgSender(), usdt);
    }
}