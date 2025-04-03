/***
 * ===================================================================
 * @author      
 * @email       
 * @version     
 * @date        
 * @description 
 * ===================================================================
**/
public class col_RollupCalculation {

	/*
	* sums up the rollup on the Parent record's rollup field based on the input child records
	* and the wraperRecord information
	* does NOT do the DML / update on the parent field
	*/
	public static Double calculateRollup(List<SObject> records, col_LookupWrapper wrapper){
		
		Double retVal;
		switch on wrapper.operation {
			when 'SUM' {
				retVal = calculateSUM(records, wrapper);
			}
			when 'MIN' {
				retVal = calculateMIN(records, wrapper);
			}
			when 'MAX' {
				retVal = calculateMAX(records, wrapper);
			}
			when 'AVG' {
				retVal = calculateAVG(records, wrapper);
			}
			when 'COUNT' {
				retVal = calculateCOUNT(records);		
			}
		}
		return retVal;
	}

	public static Double calculateSUM(List<SObject> records, col_LookupWrapper wrapper){
		Double sum = 0.0;
		for(SOBject sobj : records){
			sum += (Double) sobj.get(wrapper.childFieldAPI);
		}
		return sum;
	}

	public static Double calculateMIN(List<SObject> records, col_LookupWrapper wrapper){
		Double min = 0.0;
		if(records.size() == 0){
			return min;
		}
		Integer counter = 0;
		for(SOBject sobj : records){
			if(counter == 0){
				min = (Double) sobj.get(wrapper.childFieldAPI);
			}else if(min > (Double) sobj.get(wrapper.childFieldAPI)){
				min = (Double) sobj.get(wrapper.childFieldAPI);
			}
			counter++;
		}
		return min;
	}

	public static Double calculateMAX(List<SObject> records, col_LookupWrapper wrapper){
		Double max = 0.0;
		if(records.size() == 0){
			return max;
		}
		Integer counter = 0;
		for(SOBject sobj : records){
			if(counter == 0){
				max = (Double) sobj.get(wrapper.childFieldAPI);
			}else if(max < (Double) sobj.get(wrapper.childFieldAPI)){
				max = (Double) sobj.get(wrapper.childFieldAPI);
			}
			counter++;
		}
		return max;
	}

	public static Double calculateAVG(List<SObject> records, col_LookupWrapper wrapper){
		Double sum = 0.0;
		Double avg = 0.0;
		if(records.size() == 0){
			return avg;
		}
		for(SOBject sobj : records){
			sum += (Double) sobj.get(wrapper.childFieldAPI);
		}
		avg = (sum / records.size());
		return avg;
	}

	public static Double calculateCOUNT(List<SObject> records){
		return (Double) records.size();
	}

}