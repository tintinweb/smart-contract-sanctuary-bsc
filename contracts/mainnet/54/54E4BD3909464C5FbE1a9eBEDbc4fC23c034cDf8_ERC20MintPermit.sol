/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

pragma solidity ^0.5.0;

contract ERC20MintPermit {
    string public name;
    string public symbol;
    uint8  public decimals;

    event  TransferMinter(address indexed newMinter);
	event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;
    uint public totalSupply;
	address public minter;

    function __ERC20MintPermit_init(string memory name_, string memory symbol_, uint8 decimals_, address minter_) public {
        require(minter == address(0),"constructor once");
        __ERC20MintPermit_init_unchained(name_, symbol_, decimals_, minter_);
	}
	
	function __ERC20MintPermit_init_unchained(string memory name_, string memory symbol_, uint8 decimals_, address minter_) internal {      // public
        require(address(0) != minter_,"minter must !=0");
        name     = name_;
        symbol   = symbol_;
        decimals = decimals_;
        //DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), keccak256(bytes("1")), _chainId(), address(this)));
		//transferMinter(minter_);
		minter = minter_;
		emit TransferMinter(minter_);
    }
    
    function transferMinter(address newMinter) public {
		//require(msg.sender == minter || address(0) == minter);
		require(msg.sender == minter,"msg.sender == minter");
		minter = newMinter;
		emit TransferMinter(newMinter);
	}
	
	function mint(address dst, uint256 wad) public {
        require(msg.sender == minter,"msg.sender == minter");
		require(totalSupply + wad >= totalSupply);
        totalSupply += wad;
        balanceOf[dst] += wad;
        emit Transfer(address(0), dst, wad);
    }

	function burn(uint256 wad) public {
        burnFrom(msg.sender, wad);
    }

	function burnFrom(address src, uint256 wad) public {
        //if (minter != msg.sender && src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }
        require(balanceOf[src] >= wad);
        balanceOf[src] -= wad;
        totalSupply -= wad;

        emit Transfer(src, address(0), wad);
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }


    function _chainId() internal pure returns (uint id) {
        assembly { id := chainid() }
    }
    
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("PEAR DAO")), keccak256(bytes("1")), uint(56), 0x6a0b66710567b6beb81A71F7e9466450a91a384b));
    bytes32 public _DOMAIN_SEPARATOR;       // obsolete placeholder
    mapping (address => uint) public nonces;
	
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'permit EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'permit INVALID_SIGNATURE');
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}