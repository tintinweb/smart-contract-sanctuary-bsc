/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

interface IMNT {
    
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function transferVote(address to, uint value) external returns (bool);
}

contract BM108 {
    using SafeMath for uint;

    bytes32 private DOMAIN_SEPARATOR;
    //keccak256('popularize(address addr,uint256 len)');
    bytes32 private constant PERMIT_TYPEHASH = 0xce2c520218dcb5301165798bf7b1c57eb57c6572f887a41cc4bff0ca633df8f5;

    address public MNT = 0xEcC22434CcEFE26EFBf8a14578aF58b08930f28f;

    address public owner;

    address public constant ProjA = 0x2c56d07343187522a313b0370cdD5823fb0DB443;
    address public constant ProjB = 0xAF7FeDeaAf9De77823E77F5ba89C870C51268E06;
    address public constant ProjC = 0x5a99678D947f57560B1053a1C572e7764F99B08d;

    string public constant name = 'BM 108';
    string public constant symbol = 'BM';
    uint8 public constant decimals = 0;
    
    event Popularize(address indexed parent, address indexed children,uint timestamp);
    event Transfer(address indexed to, uint indexed t, uint bnb);

    struct Info {
        address parent;
        address[] child;
        uint v;
        uint v_have;
        uint v5_c;
        uint count;
    }

    mapping(address => Info) public spreads;
    address[] addrs;
    address[] public v5addrs;
    uint public v5_2;
    uint public v5_3;
    uint public v5_4;
    function v5_1() view public returns (uint ret) {
        ret = v5addrs.length;
    }
    uint public begin;

    uint private constant popularizeBNB = 1.08 ether;

    constructor() {
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
        spreads[msg.sender] = Info({
            parent : address(this),
            v : 0,
            v_have : 0,
            v5_c : 0,
            count : 0,
            child : new address[](0)});
        owner = msg.sender;
        begin = block.number;
        emit Popularize(address(this),msg.sender,block.timestamp);
    }

    //
    function popularize(address addr,uint8 v, bytes32 r, bytes32 s) external payable returns (bool ret) {
        assert(msg.value == popularizeBNB);
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, msg.sender, spreads[addr].child.length))
            )
        );
        require(addr == ecrecover(digest, v, r, s),"signature data error");
        popularize1(addr);
        popularize2(addr);
        popularize3(addr);
        ret = true;
    }

    //
    function popularizeFast(address addr,address temp,
        uint8 addr_v, bytes32 addr_r, bytes32 addr_s,
        uint8 temp_v, bytes32 temp_r, bytes32 temp_s)
        external payable returns (bool ret) 
    {
        assert(msg.value == popularizeBNB);
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, temp, spreads[addr].child.length))
            )
        );
        require(addr == ecrecover(digest, addr_v, addr_r, addr_s),"signature data1 error");
        require(temp == ecrecover(keccak256(abi.encodePacked(msg.sender)),temp_v, temp_r, temp_s),"signature data2 error");
        popularize1(addr);
        popularize2(addr);
        popularize3(addr);
        ret = true;
    }

    function popularize1(address addr) private returns (bool ret) {
        require(spreads[msg.sender].parent == address(0), "Parent address is not a generalization set");
        require(spreads[addr].parent != address(0), "Address has been promoted");
        addrs.push(msg.sender);
        spreads[msg.sender] = Info({
            parent : addr,
            v : 0,
            v_have : 0,
            v5_c : 0,
            count : 0,
            child : new address[](0)});
        spreads[addr].child.push(msg.sender);
        emit Popularize(addr,msg.sender,block.timestamp);    
        ret = true;
    }

    function popularize2(address addr) private returns (bool ret) {
        address addr_temp = addr;
        uint have_v = 0;
        while (addr_temp != address(this)) {
            bool update = false;
            if (spreads[addr_temp].count < 10) {
                spreads[addr_temp].count++;
            }
            if (spreads[addr_temp].v == 0) {
                if (spreads[addr_temp].count == 10) {
                    uint temp_v = 0;
                    uint c = 0;
                    for (uint i = 0; i < spreads[addr_temp].child.length; i++) {
                        if (spreads[spreads[addr_temp].child[i]].v_have > 0) {
                            c++;
                            if (c > 1) {
                                break;
                            } 
                        }
                    }
                    if (c > 1) {
                        temp_v = 2;
                    } else if (spreads[addr_temp].child.length > 2) {
                        temp_v = 1;
                    }
                    if (temp_v > 0) {
                        spreads[addr_temp].v = temp_v;
                        have_v = temp_v;
                        if (spreads[addr_temp].v_have < have_v) {
                            spreads[addr_temp].v_have = have_v;
                        }
                        update = true;
                    }
                }
            } else if (spreads[addr_temp].v < 5) {
                uint temp_v = spreads[addr_temp].v;
                uint c = 0;
                for (uint i = 0; i < spreads[addr_temp].child.length; i++) {
                    if (spreads[spreads[addr_temp].child[i]].v_have >= temp_v) {
                        c++;
                        if (c > 1) {
                            break;
                        }
                    }
                }
                if (c > 1) {
                    spreads[addr_temp].v = temp_v + 1;
                    have_v = temp_v + 1;
                    if (spreads[addr_temp].v_have < have_v) {
                        spreads[addr_temp].v_have = have_v;
                    }
                    update = true;
                    if (temp_v == 4) {
                        v5addrs.push(addr_temp);
                    }
                }
            } else if (spreads[addr_temp].v == 5) {
                uint c = 0;
                for (uint i = 0; i < spreads[addr_temp].child.length; i++) {
                    if (spreads[spreads[addr_temp].child[i]].v_have == 5) {
                        c++;
                        if (c == 4) {
                            break;
                        }
                    }
                }
                if (c > spreads[addr_temp].v5_c) {    
                    spreads[addr_temp].v5_c = c;
                    if (c == 2) {
                        v5_2++;
                    } else if (c == 3) {
                        v5_3++;
                    } else if (c == 4) {
                        v5_4++;
                    }
                }
            }
            addr_temp = spreads[addr_temp].parent;

            if (spreads[addr_temp].v_have < have_v || update || spreads[addr_temp].count < 10) {
                spreads[addr_temp].v_have = have_v;
            } else {
                break;
            }
        }
        ret = true;
    }

    function transferMNT(address to, uint value) private returns (bool) {
        if (MNT != address(0) && IMNT(MNT).balanceOf(address(this)) >= value) {
            IMNT(MNT).transferVote(to, value);
            return true;
        } else {
            return false;
        }
    }

    function popularize3(address addr) private returns (bool ret) {
        uint v008 = popularizeBNB * 8 / 108;
        uint v008_1 = v008 * 375 / 1000;
        payable(owner).transfer(v008_1);
        emit Transfer(owner, 0, v008_1);
        
        uint v008_2 = v008 * 625 / 1000;
        payable(ProjC).transfer(v008_2);
        emit Transfer(ProjC, 1, v008_2);

        transferMNT(msg.sender, 2 ether);

        payable(addr).transfer(popularizeBNB * 30 / 108);
        emit Transfer(addr, 10, popularizeBNB * 30 / 108);

        address addr_temp = spreads[addr].parent;
        uint add2 = 0;
        uint l = 0;
        uint v2 = popularizeBNB * 2 / 108;
        while (addr_temp != address(this)) {
            l++;
            if (l > 9) {
                break;
            }
            payable(addr_temp).transfer(v2);
            emit Transfer(addr_temp, 20 + l, v2);
            add2 += v2;
            addr_temp = spreads[addr_temp].parent;
        }
        
        addr_temp = addr;
        uint add3 = 0;
        uint v4_e = 0;
        uint v5_e = 0;
        while (addr_temp != address(this)) {        
            if (spreads[addr_temp].v == 1) {
                if (add3 == 0) {
                    add3 = (popularizeBNB * 10 / 108);
                    payable(addr_temp).transfer(add3);
                    emit Transfer(addr_temp,310,add3);
                }
            } else if (spreads[addr_temp].v == 2) {
                uint v = (popularizeBNB * 15 / 108);
                if (add3 < v) {
                    payable(addr_temp).transfer(v - add3);
                    emit Transfer(addr_temp,320,v - add3);
                    add3 = v;
                }
            } else if (spreads[addr_temp].v == 3) {
                uint v = (popularizeBNB * 20 / 108);
                if (add3 < v) {
                    payable(addr_temp).transfer(v - add3);
                    emit Transfer(addr_temp,330, v - add3);
                    add3 = v;
                }
            } else if (spreads[addr_temp].v == 4) {
                uint v = popularizeBNB * 25 / 108;
                if (add3 < v) {
                    payable(addr_temp).transfer(v - add3);
                    emit Transfer(addr_temp,340, v - add3);
                    add3 = v;
                } else if (add3 == v && v4_e == 0) {
                    v4_e = 1;
                    payable(addr_temp).transfer(v / 10);
                    emit Transfer(addr_temp,345, v / 10);
                }
            } else if (spreads[addr_temp].v == 5) {
                uint v = popularizeBNB * 30 / 108;
                if (add3 < v) {
                    payable(addr_temp).transfer(v - add3);
                    emit Transfer(addr_temp,350, v - add3);
                    add3 = v;
                } else if (add3 == v && v5_e == 0) {
                    v5_e = 1;
                    payable(addr_temp).transfer(v / 10);
                    emit Transfer(addr_temp,355, v / 10);
                    break;
                }
            }
            addr_temp = spreads[addr_temp].parent;
        }
        
        add3 += v4_e * (popularizeBNB * 25 / 1080) + v5_e * (popularizeBNB * 3 / 108);
        // add1 30
        // add2 2 * 9 = 18
        // add3 30 + 5.5 = 35.5
        // add4 14
        // add5 2.5
        uint A_add = (popularizeBNB * 535 / 1080) - add2 - add3;
        if (A_add > 0) {
            payable(ProjA).transfer(A_add);
            emit Transfer(ProjA, 40, A_add);
        }

        if (addrs.length % 15 == 0) {
            uint index = addrs.length / 15 - 1;
            uint v4_1 = popularizeBNB * 200 / 108;
            payable(addrs[index]).transfer(v4_1);
            emit Transfer(addrs[index], 41, v4_1);
            uint v4_2 = popularizeBNB * 10 / 108;
            payable(owner).transfer(v4_2);
            emit Transfer(owner, 42, v4_2);
        }

        if (addrs.length % 100 == 0) {
            if (v5addrs.length > 0) {
                uint ProjB_val = 0;
                uint v_5_1 = (popularizeBNB * 75 / 108) / v5addrs.length;
                uint v_5_2 = 0;
                if (v5_2 > 0) {
                    v_5_2 = (popularizeBNB * 75 / 108) / v5_2;
                } else {
                    ProjB_val = ProjB_val + (popularizeBNB * 75 / 108);
                }
                uint v_5_3 = 0;
                if (v5_3 > 0) {
                    v_5_3 = (popularizeBNB * 50 / 108) / v5_3;
                } else {
                    ProjB_val = ProjB_val + (popularizeBNB * 50 / 108);
                }
                uint v_5_4 = 0;
                if (v5_4 > 0) {
                    v_5_4 = (popularizeBNB * 50 / 108) / v5_4;
                } else {
                    ProjB_val = ProjB_val + (popularizeBNB * 50 / 108);
                }
                for (uint i = 0; i < v5addrs.length; i++) {
                    if (spreads[v5addrs[i]].v5_c == 0 || spreads[v5addrs[i]].v5_c == 1) {
                        payable(v5addrs[i]).transfer(v_5_1);
                        emit Transfer(v5addrs[i], 51, v_5_1);
                    } else if (spreads[v5addrs[i]].v5_c == 2) {
                        uint val = v_5_1 + v_5_2;
                        payable(v5addrs[i]).transfer(val);
                        emit Transfer(v5addrs[i], 52, val);
                    } else if (spreads[v5addrs[i]].v5_c == 3) {
                        uint val = v_5_1 + v_5_2 + v_5_3;
                        payable(v5addrs[i]).transfer(val);
                        emit Transfer(v5addrs[i], 53, val);
                    } else if (spreads[v5addrs[i]].v5_c == 4) {
                        uint val = v_5_1 + v_5_2 + v_5_3 + v_5_4;
                        payable(v5addrs[i]).transfer(val);
                        emit Transfer(v5addrs[i], 54, val);
                    }
                }
                if (ProjB_val > 0) {
                    emit Transfer(ProjB, 55, ProjB_val);
                    payable(ProjB).transfer(ProjB_val);    
                }
            } else {
                uint ProjB_val = 100 * (popularizeBNB * 25 / 1080);
                emit Transfer(ProjB, 55, ProjB_val);
                payable(ProjB).transfer(ProjB_val);
            }
        }
        ret = true;
    }

    function totalSupply() external view returns (uint) {
        return addrs.length;
    }

    function balanceOf(address owner_) external view returns (uint) {
        return spreads[owner_].child.length;
    }

    function allowance(address owner_, address spender_) external pure returns (uint) {
        assert(owner_ != address(0));
        assert(spender_ != address(0));
        return 0;
    }

    function approve(address spender, uint value) external pure returns (bool) {
        assert(spender != address(0));
        assert(value > 0);
        return false;
    }

    function transfer(address to, uint value) external pure returns (bool) {
        assert(to != address(0));
        assert(value > 0);
        return false;
    }

    function transferFrom(address from, address to, uint value) external pure returns (bool) {
        assert(from != address(0));
        assert(to != address(0));
        assert(value > 0);
        return false;
    }

    
    function withdraw(uint wad) external payable {
        payable(owner).transfer(wad);
    }

    function setMNT(address addr) external {
        assert(msg.sender == owner);
        MNT = addr;
    }

    function setV(address addr,uint v,uint count,uint v5_c) external {
        assert(msg.sender == owner);
        assert(v < 6 && count < 11 && v5_c < 5);
        assert(spreads[addr].v != 5 && spreads[addr].v5_c == 0);
        spreads[addr].v = v;
        spreads[addr].v_have = v;
        spreads[addr].count = count;
        spreads[addr].v5_c = v5_c;
        if (v == 5) {
            v5addrs.push(addr);
        }
        if (v5_c == 2) {
            v5_2++;
        } else if (v5_c == 3) {
            v5_2++;
            v5_3++;
        } else if (v5_c == 4) {
            v5_2++;
            v5_3++;
            v5_4++;
        }
    }

    function spreadChild(address addr) public view returns (
        address[] memory childs,
        uint[] memory v,
        uint[] memory v_have) 
    {
        uint n = spreads[addr].child.length;
        childs = spreads[addr].child;
        v = new uint[](n);
        v_have = new uint[](n);
        for (uint i = 0; i < n; i++) {
            v[i] = spreads[addrs[i]].v;
            v_have[i] = spreads[addrs[i]].v_have;
        }
    }

    function spreadParent(address addr) public view returns (
        address[] memory parents,
        uint[] memory v,
        uint[] memory v_have) 
    {
        addr = spreads[addr].parent;
        if (addr == address(0)) {
            parents = new address[](0);
            v = new uint[](0);
            v_have = new uint[](0);
            return (parents,v,v_have);
        }
        uint n = 0;
        address addr_temp = addr;
        while (addr_temp != address(this)) {
            n++;
            addr_temp = spreads[addr_temp].parent;
        }
        parents = new address[](n);
        v = new uint[](n);
        v_have = new uint[](n);

        addr_temp = addr;
        n = 0;
        while (addr_temp != address(this)) {
            parents[n] = addr_temp;
            v[n] = spreads[addr_temp].v;
            v_have[n] = spreads[addr_temp].v_have;
            n++;
            addr_temp = spreads[addr_temp].parent;
        }
    }
}