package terrorists2Mallet;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.regex.Pattern;

import cc.mallet.pipe.CharSequence2TokenSequence;
import cc.mallet.pipe.Pipe;
import cc.mallet.pipe.SerialPipes;
import cc.mallet.pipe.TokenSequence2FeatureSequence;
import cc.mallet.pipe.iterator.StringArrayIterator;
import cc.mallet.topics.ParallelTopicModel;
import cc.mallet.topics.TopicModelDiagnostics;
import cc.mallet.topics.TopicModelDiagnostics.TopicScores;
import cc.mallet.types.InstanceList;

public class terrorists2Mallet {

	public static void main(String[] args) throws IOException {		
		// Step 1: Download pol data from 4plebs archive: https://archive.org/details/4plebs-org-data-dump-2022-01
		// 		Most up to date archive found here: https://archive.org/details/4plebs-org-data-dump-2024-01
		// Step 2: Extract all case-insensitive /pol/ references to "breivik" or "brenton" or "tarrant", as described in the manuscript.
		// Step 3: Preparse extracted /pol/ posts and comments (via example preparser below) and place into "pol_"+terrorist.tsv; set third column in tsv as parsed data
		// Step 4: run topic modeling below
		// Step 5: run results through 4chan Terrorists.R to produce comparison clouds
				
		runMallet("breivik");
		runMallet("tarrant");
	}
	
	public static void runMallet(String terrorist) throws IOException {
		// for initial investigation change iterations 
		int iterations = 25000;
		double alpha = 10; // smoothing on topic distributions
        double beta = 0.01;
        int randomSeed = -1;
		int threads = 8;
        
		ArrayList<Pipe> pipeList = new ArrayList<Pipe>();
		// standard MALLET input character pipe:
		// https://mimno.github.io/Mallet/topics-devel.html
		pipeList.add( new CharSequence2TokenSequence(Pattern.compile("\\p{L}[\\p{L}\\p{P}]+\\p{L}")) );
        pipeList.add( new TokenSequence2FeatureSequence() );
        InstanceList instances = new InstanceList (new SerialPipes(pipeList));
        
        String workingDir = "/home/justin/OneDrive/manuscripts/4chan/terrorists/data/";
        
        // read in our parsed text file
        FileReader fr = new FileReader(new File(workingDir+"pol_"+terrorist+".tsv"));
		BufferedReader br = new BufferedReader(fr);
		String available = null;
		while((available = br.readLine()) != null) {
			String[] input = available.split("\t");
			// 2nd column is our parsed data
			instances.addThruPipe(new StringArrayIterator(new String[] {input[2]}));
		}
		br.close();
		fr.close();

		
		int[] wantedTopics = new int[] {6};
		for(int ldaTopics : wantedTopics) {
			ParallelTopicModel model = new ParallelTopicModel(ldaTopics, alpha,beta);
	        model.setRandomSeed(randomSeed);
	        model.addInstances(instances);
	        model.setNumThreads(threads);
	        model.setNumIterations(iterations);
			model.estimate();
			
			
//			// get diagnostics
//			TopicModelDiagnostics diag = new TopicModelDiagnostics(model, 20);
//			TopicScores ts = diag.getCoherence();
//			int sum = 0;
//	        for(double score : ts.scores) {
//	        	sum += score;
//	        }
//	        double coherence_umass = sum/ts.scores.length;
//			double ll = model.modelLogLikelihood();

			
			System.out.println("Writing...");
			FileWriter fw = new FileWriter(new File(workingDir+terrorist+"_mallet_25000it.tsv"));
	        BufferedWriter bw = new BufferedWriter(fw);
	        // write topic for each document
			for (int topic=0; topic<instances.size(); topic++) {
				double max = 0;
				int index = 0;
				double[] probabilities = model.getTopicProbabilities(topic);
				for (int i=0;i<probabilities.length;i++) {
					if (max<probabilities[i]) {
						max = probabilities[i];
						index=i;
					}
				}
				bw.write(index + "\n");
			}
	        bw.close();
	        fw.close();
			System.out.println("Done..");
		}
		return;
	}
	
	// preparsing function for /pol/ data
//	public static String messageParser(String message) {
//		String originalmessage = message;
//		message = message.replaceAll("\\\\", "");
//		message = message.replaceAll("\"", "");
//		message = message.replaceAll("\\*", "");
//		message = Normalizer.normalize(message, Normalizer.Form.NFD);
//		message = message.replaceAll("[^\\p{ASCII}]", "");
//		message = message.replaceAll("[^a-zA-Z\\s]", "");
//		message = message.trim();
//		message = message.toLowerCase();
//		// Let's remove stopwords in the message
//		weka.core.stopwords.Rainbow rb = new Rainbow();
//	
//		String[] words = message.split(" ");
//		String newMessage = "";
//		for(String word : words) {
//			String stem = word;
//			boolean stopword = rb.isStopword(word);
//			if (!rb.isStopword(word)) {
//				newMessage = newMessage + " " + stem;
//				newMessage = newMessage.trim();
//			}
//		}
//		return message;
//	}
}
