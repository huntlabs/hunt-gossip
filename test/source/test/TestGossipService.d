module test.TestGossipService;

import hunt.gossip.GossipService;
import hunt.gossip.GossipSettings;
import hunt.gossip.model.SeedMember;
import hunt.gossip.model.GossipMember;
import hunt.gossip.model.GossipState;
import hunt.gossip.event.GossipListener;
import hunt.logging;
import hunt.Integer;
import hunt.collection.ArrayList;
import hunt.collection.List;
import core.thread;

public class TestGossipService {

    static public void startGossip(int listenPort)  {
        string cluster = "testcluster";
        string ipAddress = "127.0.0.1";
        int port = 6000;
        List!(SeedMember) seedNodes = new ArrayList!(SeedMember)();
        for(int i =0 ; i < 4 ; i++)
        {
            SeedMember seed = new SeedMember();
            seed.setCluster(cluster);
            seed.setIpAddress(ipAddress);
            seed.setPort(new Integer(port + i));
            seedNodes.add(seed);
        }
        
        // for (int i = 0; i < 1; i++) {
            try
            {
                GossipService gossipService = null;
                try {
                    gossipService = new GossipService(cluster, ipAddress, new Integer(listenPort), null, seedNodes, new GossipSettings(), new class GossipListener{
                        void gossipEvent(GossipMember member, GossipState state){
                            logInfo("member:" ~ member.toString ~ "  state: " ~ state.state());
                        }
                    });
                } catch (Exception e) {
                    logError(e.msg);
                }

                gossipService.start();
            }
            catch(Throwable e)
            {
                logError(e.msg);
            }
        // }
    }
}
