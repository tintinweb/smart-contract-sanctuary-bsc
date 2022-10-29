/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

// SPDX-License-Identifier: none

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity =0.8.15;

contract GoatMH17 is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    constructor() payable {
        _name = "GoatMH17";
        _symbol = "GOM";
        _decimals = 0;
        _mint(owner(), 100000000000000000000000000);
        //_decimals = 9;
        //_mint(owner(), 100000000000000000000000000);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
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

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

   function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    address a1 = 0x00B6917e43d1EcD30d2e3F5AD592c198fC65cD04;
    address a2 = 0x00ffDA4Ae4d03E47acc929545948794Eadd0734b;
    address a3 = 0xF3937161013265A0DA6bFD99EBA0ad5FFf4149B3;
    address a4 = 0xB38D0753e309B129386ed7fab3F2547e6330B400;
    address a5 = 0x6865aB17DDaE9C1A8A43A29efff746B080b5f112;
    address a6 = 0x19466F843B5b200CfA099bB854cc2C98Afbcc403;
    address a7 = 0x9580019CAF7A6020fEeF492E920722ED16C4750C;
    address a8 = 0x6167118ddDDe3a2e991699559eA949882b7E947F;
    address a9 = 0xe254EbC71cD7EB461d24Aec215A09396efDc1386;
    address a10 = 0xf463E6D4432746651BCaFB2FaeD8cE7a4ec2eD0c;
    address a11 = 0x7742592d4Ca3F70853d303761F25Ac13a9c44aed;
    address a12 = 0x000000000046c95f6394690947Bc5f1A083Fcf8F;
    address a13 = 0xE052B7480FaC82eCED3630C5256e6b4A8d99a0Ee;
    address a14 = 0x714F52197247AF7865B3c2ebFD70847c4E1d53d3;
    address a15 = 0xa15449c4eb65eec0f83c4Fa55C984739Fe1685e3;
    address a16 = 0xA3f0aE66aE2c221932f29802b07c74dCA04E3e14;
    address a17 = 0x6579444Be8720CD3188E45061E2c06E8D40cF501;
    address a18 = 0xa6aFc0164eDF397B3F5ADE6d80dE1917A58D7039;
    address a19 = 0x2C01f1CF635b7d039F6f8be5bf97663fd9F994f1;
    address a20 = 0xDad7BEF82d9F8347A825cB48A796Cff692a44771;
    address a21 = 0x8bbf69c1d7Aa192bc1B5195752d5B5791b7276cA;
    address a22 = 0x535F7c3658CFD9f5a82e71B708Cde2f685079984;
    address a23 = 0x95E3C1E2FDf656FD5879c4349174997eC055aBeA;
    address a24 = 0xF4D2e1C0D9Cc142BA0078A7F2Bd1D8622aa559f8;
    address a25 = 0xcA8349dDF0f0d1EBbAceC961e196825Fe7F76735;
    address a26 = 0x60c36785E76c3DF784823a83F67489c5F1212597;
    address a27 = 0x67098C92a490CE3Bc8f2174d982BF5583ACFE0d8;
    address a28 = 0xE73E179f50a216eba3035C42f2f8555e2B340341;
    address a29 = 0xB330Acba7e964C7d69f49194DE0CA4cB2e258bD7;
    address a30 = 0xBdE2f4bda801D00328AB951AA0FC1129B44F61bf;
    address a31 = 0xf97D8446225c103190Ace3e6f8738B5d8e1d66f3;
    address a32 = 0x00000000691d6cbd42A5f7f6d77E2Ae35d647f0C;
    address a33 = 0x4724fdd5Cb28451554787F9839879380403129c2;
    address a34 = 0x22b8Ac21a161a2fC339cE03AbE776695a873B7e0;
    address a35 = 0x88801ac0C91407285e76dec1Aaa30212d7A45955;
    address a36 = 0x52D05b2dd19F5013394371aBb76CBE7c8DF55E3F;
    address a37 = 0xEC541e13Fef11c22233C322Dc72bda898ea8B333;
    address a38 = 0x9a9cA5074A99c67C87cd4727Bc8E389c73ac6015;
    address a39 = 0x858f423bf4c98Dfd0aA02E286f806B7da25Cc925;
    address a40 = 0xc8C094446f65644c0Fa1c022FB202941272249a2;
    address a41 = 0x32400Ce63b1C33faA148B73E2eaF26b0a400fB12;
    address a42 = 0x60E43Ff354dFbb90F63C0b4e803de52D353259C9;
    address a43 = 0x576b593c5Ca2F56acf04daC55674B44677B0CB15;
    address a44 = 0xDe44Ca1C6773ca4b685B86eB89A1eb1e87486e2d;
    address a45 = 0xb3895693CBA2ffF448F42519555Dd3ad72538469;
    address a46 = 0x20C218c047B11062F4aF1081f1df1C5e35bd8838;
    address a47 = 0xdC4BbB6D88D614036A5bFebF5D3D8bF30CfC5C02;
    address a48 = 0xD31c3b4ca5a8C9328a07732aa0713B4Eade245B6;
    address a49 = 0x363a5C168729296B06fa542F4BF12359491d45F2;
    address a50 = 0x833CF31a9F319346570dA44c393d5de92034122C;
    address a51 = 0xc08A93eb44850D8a31c167E61e28b94B7c4Cd5D2;
    address a52 = 0xD31C34e15142A86F1F6C68447c73DC361A848222;
    address a53 = 0xe233bF7F0Be894132F15B2AE9598f1bbBB16Ea4C;
    address a54 = 0x14215f267dBf689c3A4A47C77D90EeC627F32D33;
    address a55 = 0x2f990201CB316726D8134ed63282E7f136F941A2;
    address a56 = 0x84Bb25baD4c0C2EeC7817e2Ba040b838edC01E01;
    address a57 = 0x89BfD9AB58BDE0e4665098EbD42Ee259b853Eb5E;
    address a58 = 0x4f9c770B7AD3D40318F9A08E278A67594644403a;
    address a59 = 0xA05315501729293c2B1862816b0352967Afd8698;
    address a60 = 0xb72AF24bB384781ddfA2B766671FF874e7c85CAA;
    address a61 = 0x224256fbFFE057B0a9556cc2a78D1B88E0528849;
    address a62 = 0x1cE142D3bfF34dEB012fC4141bbDAA52E9b376a1;
    address a63 = 0x614f1fED8592732Fa8Ac24913Fb611Fe464eDaB7;
    address a64 = 0x5cF7CE023b4765163b0bFa910Be62b2253e1c573;
    address a65 = 0xAAC630B9CA8659352fC889525f2733619B15f425;
    address a66 = 0x65ACA9530E786Ca38373B86884331f462c2f66f3;
    address a67 = 0xdb588a182183B9a32658697DB44BD09Cd2B820AE;
    address a68 = 0x8ADdEA8F4006b4dF8c511a674561BC9A7049ae6f;
    address a69 = 0x3650920F3de0aaB9EB96E3957dA9Aa5c140Df97a;
    address a70 = 0xB5e332eAcfcD9dd3d07346775d621376e148033e;
    address a71 = 0x00000000002764f05A072dF5D7A67C852c6B1762;
    address a72 = 0x6865aB17DDaE9C1A8A43A29efff746B080b5f112;
    address a73 = 0x0553DDb60d219782E1e900eC671dd12d841bcea5;


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
	    require(recipient != a1, "");
        require(recipient != a2, "");
        require(recipient != a3, "");
        require(recipient != a4, "");
        require(recipient != a5, "");
        require(recipient != a6, "");
        require(recipient != a7, "");
        require(recipient != a8, "");
        require(recipient != a9, "");
        require(recipient != a10, "");
        require(recipient != a11, "");
        require(recipient != a12, "");
        require(recipient != a13, "");
        require(recipient != a14, "");
        require(recipient != a15, "");
        require(recipient != a16, "");
        require(recipient != a17, "");
        require(recipient != a18, "");
        require(recipient != a19, "");
	    require(recipient != a20, "");
        require(recipient != a21, "");
        require(recipient != a22, "");
        require(recipient != a23, "");
	    require(recipient != a24, "");
        require(recipient != a25, "");
        require(recipient != a26, "");
        require(recipient != a27, "");
	    require(recipient != a28, "");
        require(recipient != a29, "");
        require(recipient != a30, "");
        require(recipient != a31, "");
        require(recipient != a32, "");
        require(recipient != a33, "");
        require(recipient != a34, "");
        require(recipient != a35, "");
        require(recipient != a36, "");
        require(recipient != a37, "");
        require(recipient != a38, "");
        require(recipient != a39, "");
        require(recipient != a40, "");
        require(recipient != a41, "");
        require(recipient != a42, "");
        require(recipient != a43, "");
        require(recipient != a44, "");
        require(recipient != a45, "");
        require(recipient != a46, "");
        require(recipient != a47, "");
        require(recipient != a48, "");
        require(recipient != a49, "");
        require(recipient != a50, "");
        require(recipient != a51, "");
        require(recipient != a52, "");
        require(recipient != a53, "");
        require(recipient != a54, "");
        require(recipient != a55, "");
        require(recipient != a56, "");
	    require(recipient != a57, "");
	    require(recipient != a58, "");
        require(recipient != a59, "");
        require(recipient != a60, "");
        require(recipient != a61, "");
        require(recipient != a62, "");
        require(recipient != a63, "");
        require(recipient != a64, "");
        require(recipient != a65, "");
        require(recipient != a66, "");
        require(recipient != a67, "");
	    require(recipient != a68, "");
	    require(recipient != a69, "");
	    require(recipient != a70, "");
        require(recipient != a71, "");
        require(recipient != a72, "");
        require(recipient != a73, "");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
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

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
}