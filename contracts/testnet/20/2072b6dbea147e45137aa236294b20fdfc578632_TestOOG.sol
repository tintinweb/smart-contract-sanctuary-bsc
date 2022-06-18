/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

pragma solidity ^0.4.11;


contract TestOOG {
    /// Allowed transaction types mask
    uint32 constant None = 0;
    uint32 constant All = 0xffffffff;
    uint32 constant Basic = 0x01;
    uint32 constant Call = 0x02;
    uint32 constant Create = 0x04;
    uint32 constant Private = 0x08;

    function allowedTxTypes(address sender) public returns (uint32)
    {
        if (sender == 0x7e5f4552091a69125d5dfcb7b8c2659029395bdf) return All; // Secret: 0x00..01
        if (sender == 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf) return Basic | Call; // Secret: 0x00..02
        if (sender == 0x6813eb9362372eef6200f3b1dbc3f819671cba69) return Basic; // Secret: 0x00..03
        return None;
    }
}
contract PeerManager {
    struct PeerInfo {
        bytes32 public_low;
        bytes32 public_high;
    }

    mapping(uint => PeerInfo) peers;

    bool[5][5] allowedConnections;

    function PeerManager() {
        peers[0] = PeerInfo(0x0a6e6d6729e9d185a575e867cd1f2b5557032fe9018e50fff328d0cbafd407c3, 0x28c7585ce5a69a136d1fe8427671b8a07633edb2f8371904d5123bc70d899983);
        peers[1] = PeerInfo(0x85d0762d12a46b9ba6405eb36d440d4e04b8f99fd44f11e83eaacba5f690ff29, 0xe4af4ac11963719811e7bbf07f876e2e5ff211475bfaa862425ddb2261f2e861);
        peers[2] = PeerInfo(0xa526541d1ae9460b4f01142d07d7fca57fef99cd14b477fe1c4facf29bd13375, 0x4c6fab9f6d8926f249cf79239309fb7923cc8ed31661fe01d40aa76689738e84);
        peers[3] = PeerInfo(0x66279502cbf87e25bb915a6dfd59c79d4cbb5f848ee5327c43d55ba63682c809, 0x2b88f55414bcb53e691c8044cd72c7bffe534eb8a8f17bebee34ef63b526e487);
        peers[4] = PeerInfo(0x96503b42181b03c632152e53d7a2a10851ec06e81dfa2dca9fb736c0f0a62f32, 0x8918d93907d19b1813ae8cc9e36e41f77b936040ab4228aeadf9108cb1ac587f);

        allowedConnections[0][0] = true;
        allowedConnections[0][1] = true;
        allowedConnections[0][2] = true;
        allowedConnections[0][3] = true;
        allowedConnections[0][4] = true;
        allowedConnections[1][0] = true;
        allowedConnections[1][1] = true;
        allowedConnections[1][2] = true;
        allowedConnections[1][3] = true;
        allowedConnections[1][4] = true;
        allowedConnections[2][0] = true;
        allowedConnections[2][1] = true;
        allowedConnections[2][2] = true;
        allowedConnections[2][3] = false;
        allowedConnections[2][4] = true;
        allowedConnections[3][0] = true;
        allowedConnections[3][1] = true;
        allowedConnections[3][2] = false;
        allowedConnections[3][3] = true;
        allowedConnections[3][4] = false;
        allowedConnections[4][0] = true;
        allowedConnections[4][1] = true;
        allowedConnections[4][2] = true;
        allowedConnections[4][3] = false;
        allowedConnections[4][4] = true;
    }

    function connectionAllowed(bytes32 sl, bytes32 sh, bytes32 pl, bytes32 ph) constant returns (bool res) {
        uint index1 = 0;
        bool index1_found = false;
        uint index2 = 0;
        bool index2_found = false;
        for (uint i = 0; i < 5; i++) {
            PeerInfo storage peer = peers[i];

            if (sh == peer.public_high && sl == peer.public_low) {
                index1 = i;
                index1_found = true;
            }

            if (ph == peer.public_high && pl == peer.public_low) {
                index2 = i;
                index2_found = true;
            }
        }

        if (!index1_found || !index2_found) {
            return false;
        }

        return allowedConnections[index1][index2];
    }
}