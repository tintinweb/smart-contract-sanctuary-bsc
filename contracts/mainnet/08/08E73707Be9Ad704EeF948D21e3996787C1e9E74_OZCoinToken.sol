/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

pragma solidity ^0.8.7;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function power(uint256 a,uint p) internal pure returns (uint256) {
        uint res = 1;
        while(p != 0) {
            if(p & 1 == 1) {
                res = res * a;
            }
            p >>= 1;
            a = a * a;
        }
    return res;
}

}

interface IBEP20 {

    function decimals() external view returns (uint8);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract OZCoinToken {

    using SafeMath for uint;

    string public constant name = "Ozcoin";

    string public constant symbol = "OZC";

    uint8 public constant decimals = 18;

    uint256 private _totalSupply;

    address private multiSignWallet;

    mapping(address => uint) private supportedContractAddress;

    mapping(address => uint) private balances;

    mapping (address => mapping (address => uint)) public _allowance;

    mapping (address => bool) public isFreeze;

    mapping (address => uint) public nonces;

    //域分隔符 用于验证permitApprove
    bytes32 private DOMAIN_SEPARATOR;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event DecreaseApprove(address indexed _owner, address indexed _spender, uint _value);

    event Freeze(address addr);

    //approve许可
    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    function hashPermit(Permit memory permit) private view returns (bytes32){
        return keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)'),
                    permit.owner,
                    permit.spender,
                    permit.value,
                    permit.nonce,
                    permit.deadline
                    ))
            )
        );
    }

    modifier onlyMultiSign() {
        require(msg.sender == multiSignWallet,'Forbidden');
        _;
    }

    function freezeAddress(address addr) onlyMultiSign external returns (bool) {
        isFreeze[addr] = true;
        emit Freeze(addr);
        return true;
    }

    function totalSupply() external view returns (uint){
        return _totalSupply;
    }

    function burnFreezeAddressCoin(address freezeAddr,uint _value) onlyMultiSign external returns (bool success) {
        require(isFreeze[freezeAddr],"Not freeze");
        require(balances[freezeAddr] >= _value,"Insufficient funds");
        burn(freezeAddr,_value);
        return true;
    }


    function mint(address spender,uint _value) onlyMultiSign external returns (bool success) {
        return _mint(_value,spender);
    }

    //铸币
    function _mint(uint _value,address spender) private returns (bool success) {
        address _from = 0x0000000000000000000000000000000000000000;
        balances[spender] = balances[spender].add(_value);
        _totalSupply = _totalSupply.add(_value);
        emit Transfer(_from, spender, _value);
        return true;
    }

    //销币
    function burn(address owner,uint _value) private returns (bool success) {
        address _to = 0x0000000000000000000000000000000000000000;
        require(_value <= balances[owner],"Insufficient funds");
        balances[owner] = balances[owner].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Transfer(owner, _to, _value);
        return true;
    }

    function balanceOf(address _owner) external view returns (uint balance) {
        return balances[_owner];
    }

    function doTransfer(address _from, address _to, uint _value) private {
        require(!isFreeze[_from],"Been frozen");
        uint fromBalance = balances[_from];
        require(fromBalance >= _value, "Insufficient funds");
        balances[_from] = fromBalance.sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function doApprove(address owner,address _spender,uint _value) private {
        _allowance[owner][_spender] = _value;
        emit Approval(owner,_spender,_value);
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        address _owner = msg.sender;
        doTransfer(_owner,_to,_value);
        return true;
    }

    function approve(address _spender, uint _value) external returns (bool success){
        address _sender = msg.sender;
        doApprove(_sender,_spender,_value);
        return true;
    }

    function decreaseApprove(address _spender, uint _value) external returns (bool success){
        address _sender = msg.sender;
        uint remaining = _allowance[_sender][_spender];
        remaining = remaining.sub(_value);
        _allowance[_sender][_spender] = remaining;
        emit DecreaseApprove(_sender,_spender,_value);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint remaining){
        return _allowance[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool success){
        address _sender = msg.sender;
        uint remaining = _allowance[_from][_sender];
        require(_value <= remaining,"Insufficient remaining allowance");
        remaining = remaining.sub(_value);
        _allowance[_from][_sender] = remaining;
        doTransfer(_from, _to, _value);
        return true;
    }

    function permitApprove(Permit memory permit, uint8 v, bytes32 r, bytes32 s) external {
        require(permit.deadline >= block.timestamp, "Expired");
        require(permit.nonce == nonces[permit.owner]++, "Invalid Nonce");
        bytes32 digest = hashPermit(permit);
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == permit.owner, "Invalid Signature");
        doApprove(permit.owner, permit.spender, permit.value);
    }

    function allowSupportedAddress(address contractAddress) onlyMultiSign external returns(bool) {
        supportedContractAddress[contractAddress] = 1;
        return true;
    }

    function removeSupportedAddressAllow(address contractAddress) onlyMultiSign external returns(bool) {
        supportedContractAddress[contractAddress] = 0;
        return true;
    }

    //使用稳定币兑换OZC
    function exchange(address spender,address contractAddress,uint amount) external{
        require(supportedContractAddress[contractAddress] == 1,"Don't support");
        address owner = msg.sender;
        uint allowanceValue = IBEP20(contractAddress).allowance(owner,address(this));
        require(allowanceValue >= amount,"Insufficient allowance");
        bool res = IBEP20(contractAddress).transferFrom(owner,address(this),amount);
        require(res,"Transfer failed");
        uint8 erc20decimals = IBEP20(contractAddress).decimals();
        //proportion ozcoin对应erc20比例
        //根据精度差距计算兑换数量默认1:1
        uint ozcAmount = amount;
        uint ten = 10;
        if (erc20decimals<decimals) {
            uint8 decimalsDifference = decimals - erc20decimals;
            uint proportion = ten.power(decimalsDifference);
            ozcAmount = amount.mul(proportion);
        }
        if (erc20decimals>decimals) {
            uint8 decimalsDifference = erc20decimals - decimals;
            uint proportion = ten.power(decimalsDifference);
            ozcAmount = amount.div(proportion);
        }
        _mint(ozcAmount,spender);
    }

    //使用OZC兑换稳定币
    function reverseExchange(address spender,address contractAddress,uint amount) external{
        require(supportedContractAddress[contractAddress] == 1,"Don't support");
        address owner = msg.sender;
        uint8 erc20decimals = IBEP20(contractAddress).decimals();
        //proportion ozcoin对应erc20比例
        //根据精度差距计算兑换数量默认1:1
        uint exAmount = amount;
        uint ten = 10;
        if (erc20decimals<decimals) {
            uint8 decimalsDifference = decimals - erc20decimals;
            uint proportion = ten.power(decimalsDifference);
            exAmount = amount.div(proportion);
        }
        if (erc20decimals>decimals) {
            uint8 decimalsDifference = erc20decimals - decimals;
            uint proportion = ten.power(decimalsDifference);
            exAmount = amount.mul(proportion);
        }
        burn(owner,amount);
        IBEP20(contractAddress).transfer(spender,exAmount);
    }

    function withdrawToken(address contractAddress,address spender,uint amount) onlyMultiSign external {
        IBEP20(contractAddress).transfer(spender,amount);
    }

    constructor (address multiSignWalletAddress) {
        multiSignWallet = multiSignWalletAddress;
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );

    }

}